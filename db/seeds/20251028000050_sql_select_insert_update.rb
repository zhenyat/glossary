################################################################################
#   File:     db/seeds/20251028000050_sql_select_insert_update.rb
#   Purpose:  Seed SQL commands (SELECT/INSERT/UPDATE) with examples
#             Convention: examples.title = snippet, descr_en/descr_ru = phrase
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
# frozen_string_literal: true

def ensure_category!(en, ru)
  Category.find_or_create_by!(name_en: en) { |c| c.name_ru = ru }
end

def upsert_example!(command:, snippet:, phrase_en:, phrase_ru:)
  ex = Example.find_by(command: command, title: snippet) ||
       Example.find_by(command: command, title: phrase_en)
  if ex
    ex.update!(title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  else
    Example.create!(command: command, title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  end
end

def upsert_command!(category:, title:, descr_en:, descr_ru:, examples:)
  cmd = Command.find_or_create_by!(category: category, title: title)
  if cmd.descr_en != descr_en || cmd.descr_ru != descr_ru
    cmd.update!(descr_en: descr_en, descr_ru: descr_ru)
  end
  examples.each do |snip, phr_en, phr_ru|
    upsert_example!(command: cmd, snippet: snip, phrase_en: phr_en, phrase_ru: phr_ru)
  end
end

sql_cat = ensure_category!("sql", "SQL")

# SELECT
select_examples = [
  ["SELECT en, ru FROM terms WHERE deleted_on IS NULL LIMIT 10;",
    "Select specific columns", "Выбрать конкретные столбцы"],
  ["SELECT DISTINCT en FROM terms;",
    "Distinct values", "Уникальные значения"],
  ["SELECT COUNT(*) FROM terms;",
    "Count rows", "Подсчитать строки"],
  ["SELECT category_id, COUNT(*) FROM terms GROUP BY category_id;",
    "Group and count", "Сгруппировать и посчитать"],
  ["SELECT t.en, c.name_en FROM terms t JOIN categories c ON c.id = t.category_id LIMIT 10;",
    "Join categories", "Соединить с категориями"],
  ["SELECT en || ' (' || ru || ')' AS display FROM terms LIMIT 5;",
    "Concatenate strings", "Конкатенация строк"],
  ["SELECT id, strftime('%Y-%m-%d', created_at) AS created FROM terms LIMIT 5;",
    "Format date/time", "Форматировать дату/время"],
  ["SELECT en FROM terms WHERE en LIKE 'J%' ORDER BY en COLLATE NOCASE;",
    "Pattern and order", "Шаблон и сортировка"]
]

upsert_command!(
  category: sql_cat,
  title: "SELECT",
  descr_en: "Retrieve rows; filter, sort, join, and aggregate.",
  descr_ru: "Извлекать строки; фильтрация, сортировка, соединения и агрегирование.",
  examples: select_examples
)

# INSERT
insert_examples = [
  ["INSERT INTO terms(category_id, en, ru) VALUES ((SELECT id FROM categories WHERE name_en='data-formats'), 'JSON', 'JSON');",
    "Insert one row", "Вставить одну строку"],
  ["INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, 'CSV', 'CSV'), (/*cat_id*/, 'XML', 'XML');",
    "Insert multiple rows", "Вставить несколько строк"],
  ["INSERT OR IGNORE INTO terms(category_id, en, ru) VALUES (/*cat_id*/, 'JSON', 'JSON');",
    "Ignore duplicates", "Игнорировать дубликаты"],
  ["INSERT INTO terms(category_id, en, ru) SELECT id, 'YAML', 'YAML' FROM categories WHERE name_en='data-formats';",
    "Insert from SELECT", "Вставить из запроса"],
  ["INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, 'JSON', 'JSON') ON CONFLICT(category_id, en) DO UPDATE SET ru=excluded.ru;",
    "Upsert (ON CONFLICT DO UPDATE)", "Upsert (при конфликте — обновление)"]
]

upsert_command!(
  category: sql_cat,
  title: "INSERT",
  descr_en: "Add new rows; supports multi-row, INSERT ... SELECT, and upsert.",
  descr_ru: "Добавлять строки; поддерживает множественные вставки, INSERT ... SELECT и upsert.",
  examples: insert_examples
)

# UPDATE
update_examples = [
  ["UPDATE terms SET descr_en = 'Structured text format' WHERE en = 'JSON';",
    "Update description", "Обновить описание"],
  ["UPDATE terms SET deleted_on = CURRENT_TIMESTAMP WHERE en = 'XML';",
    "Soft delete a term", "Мягкое удаление термина"],
  ["UPDATE terms SET category_id = (SELECT id FROM categories WHERE name_en='sql') WHERE en = 'JOIN';",
    "Update with subquery", "Обновление через подзапрос"],
  ["UPDATE terms SET abbr_en = substr(en,1,3) WHERE length(en) >= 3;",
    "Set abbreviation via function", "Установить аббревиатуру функцией"],
  ["UPDATE terms SET ru = trim(ru);",
    "Normalize whitespace", "Нормализовать пробелы"],
  ["UPDATE terms SET en = upper(en) WHERE category_id = (SELECT id FROM categories WHERE name_en='sql');",
    "Uppercase English field (SQL terms)", "Верхний регистр для английского поля (SQL)"]
]

upsert_command!(
  category: sql_cat,
  title: "UPDATE",
  descr_en: "Modify existing rows; filter with WHERE, use subqueries and functions.",
  descr_ru: "Изменять существующие строки; фильтрация WHERE, подзапросы и функции.",
  examples: update_examples
)

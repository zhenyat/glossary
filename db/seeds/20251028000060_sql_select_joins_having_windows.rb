################################################################################
#   File:     db/seeds/20251028000060_sql_select_joins_having_windows.rb
#   Purpose:  Extend SELECT with JOIN/HAVING/window function examples
#             Convention: examples.title = snippet, descr_* = phrase
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

def upsert_command!(category:, title:, descr_en:, descr_ru:)
  cmd = Command.find_or_create_by!(category: category, title: title)
  if cmd.descr_en != descr_en || cmd.descr_ru != descr_ru
    cmd.update!(descr_en: descr_en, descr_ru: descr_ru)
  end
  cmd
end

sql_cat = ensure_category!("sql", "SQL")

select_cmd = upsert_command!(
  category: sql_cat,
  title: "SELECT",
  descr_en: "Retrieve rows; joins, filtering, grouping (HAVING), window functions.",
  descr_ru: "Извлекать строки; соединения, фильтрация, группировка (HAVING), оконные функции."
)

examples = [
  # JOINs
  [
    "SELECT c.name_en, COUNT(*) AS term_count
     FROM terms t
     JOIN categories c ON c.id = t.category_id
     GROUP BY c.id
     ORDER BY term_count DESC
     LIMIT 10;",
    "Count terms per category (INNER JOIN)",
    "Подсчитать термины по категориям (INNER JOIN)"
  ],
  [
    "SELECT c.name_en, COUNT(t.id) AS term_count
     FROM categories c
     LEFT JOIN terms t ON t.category_id = c.id
     GROUP BY c.id
     ORDER BY term_count DESC, c.name_en;",
    "Left join: include categories even with no terms",
    "LEFT JOIN: включать категории даже без терминов"
  ],
  [
    "SELECT c.name_en, cmd.title AS command, e.title AS example
     FROM examples e
     JOIN commands cmd   ON cmd.id = e.command_id
     JOIN categories c   ON c.id  = cmd.category_id
     ORDER BY c.name_en, cmd.title, e.title
     LIMIT 20;",
    "Join commands with examples and categories",
    "Соединить команды с примерами и категориями"
  ],

  # HAVING
  [
    "SELECT c.name_en, COUNT(*) AS term_count
     FROM terms t
     JOIN categories c ON c.id = t.category_id
     GROUP BY c.id
     HAVING COUNT(*) >= 2
     ORDER BY term_count DESC;",
    "HAVING: categories with at least 2 terms",
    "HAVING: категории как минимум с 2 терминами"
  ],
  [
    "SELECT c.name_en,
            SUM(CASE WHEN t.deleted_on IS NULL THEN 1 ELSE 0 END) AS active_terms
     FROM categories c
     LEFT JOIN terms t ON t.category_id = c.id
     GROUP BY c.id
     HAVING active_terms > 0
     ORDER BY active_terms DESC, c.name_en;",
    "HAVING: only categories with active terms",
    "HAVING: только категории с активными терминами"
  ],

  # Window functions
  [
    "SELECT c.name_en, t.en,
            ROW_NUMBER() OVER (PARTITION BY c.name_en ORDER BY t.en) AS rn
     FROM terms t
     JOIN categories c ON c.id = t.category_id
     ORDER BY c.name_en, rn
     LIMIT 20;",
    "Window: row number per category",
    "Оконная: порядковый номер в категории"
  ],
  [
    "SELECT c.name_en, t.en,
            COUNT(*) OVER (PARTITION BY c.name_en) AS per_category
     FROM terms t
     JOIN categories c ON c.id = t.category_id
     ORDER BY c.name_en, t.en
     LIMIT 20;",
    "Window: count per category (as a column)",
    "Оконная: количество в категории (как столбец)"
  ],
  [
    "SELECT c.name_en, t.en,
            LENGTH(t.en) AS len,
            AVG(LENGTH(t.en)) OVER (PARTITION BY c.name_en) AS avg_len
     FROM terms t
     JOIN categories c ON c.id = t.category_id
     ORDER BY c.name_en, len DESC
     LIMIT 20;",
    "Window: average term length per category",
    "Оконная: средняя длина термина по категории"
  ],
  [
    "SELECT t.en,
            RANK() OVER (ORDER BY LENGTH(t.en) DESC) AS len_rank
     FROM terms t
     ORDER BY len_rank, t.en
     LIMIT 20;",
    "Window: rank terms by length",
    "Оконная: ранжировать термины по длине"
  ]
]

examples.each do |snippet, phr_en, phr_ru|
  upsert_example!(command: select_cmd, snippet: snippet.squish, phrase_en: phr_en, phrase_ru: phr_ru)
end

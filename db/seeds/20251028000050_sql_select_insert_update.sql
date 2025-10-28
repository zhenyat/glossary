/***************************************************
 *  File:       db/seeds/20251028000050_sql_select_insert_update.sql
 *  Purpose:    Seed SQL commands (SELECT/INSERT/UPDATE) with examples
 *              Convention: examples.title = snippet, descr_* = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Commands (UPSERT on (category_id, title))
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'SELECT', 'Retrieve rows; filter, sort, join, and aggregate.', 'Извлекать строки; фильтрация, сортировка, соединения и агрегирование.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'INSERT', 'Add new rows; supports multi-row, INSERT ... SELECT, and upsert.', 'Добавлять строки; поддерживает множественные вставки, INSERT ... SELECT и upsert.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'UPDATE', 'Modify existing rows; filter with WHERE, use subqueries and functions.', 'Изменять существующие строки; фильтрация WHERE, подзапросы и функции.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- SELECT examples
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en, ru FROM terms WHERE deleted_on IS NULL LIMIT 10;', 'Select specific columns', 'Выбрать конкретные столбцы'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT DISTINCT en FROM terms;', 'Distinct values', 'Уникальные значения'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT COUNT(*) FROM terms;', 'Count rows', 'Подсчитать строки'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT category_id, COUNT(*) FROM terms GROUP BY category_id;', 'Group and count', 'Сгруппировать и посчитать'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT t.en, c.name_en FROM terms t JOIN categories c ON c.id = t.category_id LIMIT 10;', 'Join categories', 'Соединить с категориями'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en || '' ('' || ru || '')'' AS display FROM terms LIMIT 5;', 'Concatenate strings', 'Конкатенация строк'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT id, strftime(''%Y-%m-%d'', created_at) AS created FROM terms LIMIT 5;', 'Format date/time', 'Форматировать дату/время'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en FROM terms WHERE en LIKE ''J%'' ORDER BY en COLLATE NOCASE;', 'Pattern and order', 'Шаблон и сортировка'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- INSERT examples
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'INSERT INTO terms(category_id, en, ru) VALUES ((SELECT id FROM categories WHERE name_en=''data-formats''), ''JSON'', ''JSON'');', 'Insert one row', 'Вставить одну строку'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, ''CSV'', ''CSV''), (/*cat_id*/, ''XML'', ''XML'');', 'Insert multiple rows', 'Вставить несколько строк'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'INSERT OR IGNORE INTO terms(category_id, en, ru) VALUES (/*cat_id*/, ''JSON'', ''JSON'');', 'Ignore duplicates', 'Игнорировать дубликаты'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'INSERT INTO terms(category_id, en, ru) SELECT id, ''YAML'', ''YAML'' FROM categories WHERE name_en=''data-formats'';', 'Insert from SELECT', 'Вставить из запроса'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, ''JSON'', ''JSON'') ON CONFLICT(category_id, en) DO UPDATE SET ru=excluded.ru;', 'Upsert (ON CONFLICT DO UPDATE)', 'Upsert (при конфликте — обновление)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- UPDATE examples
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET descr_en = ''Structured text format'' WHERE en = ''JSON'';', 'Update description', 'Обновить описание'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET deleted_on = CURRENT_TIMESTAMP WHERE en = ''XML'';', 'Soft delete a term', 'Мягкое удаление термина'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET category_id = (SELECT id FROM categories WHERE name_en=''sql'') WHERE en = ''JOIN'';', 'Update with subquery', 'Обновление через подзапрос'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET abbr_en = substr(en,1,3) WHERE length(en) >= 3;', 'Set abbreviation via function', 'Установить аббревиатуру функцией'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET ru = trim(ru);', 'Normalize whitespace', 'Нормализовать пробелы'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET en = upper(en) WHERE category_id = (SELECT id FROM categories WHERE name_en=''sql'');', 'Uppercase English field (SQL terms)', 'Верхний регистр для английского поля (SQL)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

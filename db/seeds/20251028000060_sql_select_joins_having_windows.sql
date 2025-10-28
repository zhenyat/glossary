/***************************************************
 *  File:       db/seeds/20251028000060_sql_select_joins_having_windows.sql
 *  Purpose:    Extend SELECT with JOIN/HAVING/window function examples
 *              Convention: examples.title = snippet, descr_* = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Ensure SELECT command exists and update description (UPSERT)
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'SELECT',
       'Retrieve rows; joins, filtering, grouping (HAVING), window functions.',
       'Извлекать строки; соединения, фильтрация, группировка (HAVING), оконные функции.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title)
DO UPDATE SET
  descr_en = excluded.descr_en,
  descr_ru = excluded.descr_ru;

-- JOINs
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, COUNT(*) AS term_count
 FROM terms t
 JOIN categories c ON c.id = t.category_id
 GROUP BY c.id
 ORDER BY term_count DESC
 LIMIT 10;',
'Count terms per category (INNER JOIN)',
'Подсчитать термины по категориям (INNER JOIN)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, COUNT(t.id) AS term_count
 FROM categories c
 LEFT JOIN terms t ON t.category_id = c.id
 GROUP BY c.id
 ORDER BY term_count DESC, c.name_en;',
'Left join: include categories even with no terms',
'LEFT JOIN: включать категории даже без терминов'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, cmd.title AS command, e.title AS example
 FROM examples e
 JOIN commands cmd   ON cmd.id = e.command_id
 JOIN categories c   ON c.id  = cmd.category_id
 ORDER BY c.name_en, cmd.title, e.title
 LIMIT 20;',
'Join commands with examples and categories',
'Соединить команды с примерами и категориями'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- HAVING
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, COUNT(*) AS term_count
 FROM terms t
 JOIN categories c ON c.id = t.category_id
 GROUP BY c.id
 HAVING COUNT(*) >= 2
 ORDER BY term_count DESC;',
'HAVING: categories with at least 2 terms',
'HAVING: категории как минимум с 2 терминами'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en,
        SUM(CASE WHEN t.deleted_on IS NULL THEN 1 ELSE 0 END) AS active_terms
 FROM categories c
 LEFT JOIN terms t ON t.category_id = c.id
 GROUP BY c.id
 HAVING active_terms > 0
 ORDER BY active_terms DESC, c.name_en;',
'HAVING: only categories with active terms',
'HAVING: только категории с активными терминами'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Window functions (SQLite 3.25+)
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, t.en,
        ROW_NUMBER() OVER (PARTITION BY c.name_en ORDER BY t.en) AS rn
 FROM terms t
 JOIN categories c ON c.id = t.category_id
 ORDER BY c.name_en, rn
 LIMIT 20;',
'Window: row number per category',
'Оконная: порядковый номер в категории'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, t.en,
        COUNT(*) OVER (PARTITION BY c.name_en) AS per_category
 FROM terms t
 JOIN categories c ON c.id = t.category_id
 ORDER BY c.name_en, t.en
 LIMIT 20;',
'Window: count per category (as a column)',
'Оконная: количество в категории (как столбец)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT c.name_en, t.en,
        LENGTH(t.en) AS len,
        AVG(LENGTH(t.en)) OVER (PARTITION BY c.name_en) AS avg_len
 FROM terms t
 JOIN categories c ON c.id = t.category_id
 ORDER BY c.name_en, len DESC
 LIMIT 20;',
'Window: average term length per category',
'Оконная: средняя длина термина по категории'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT t.en,
        RANK() OVER (ORDER BY LENGTH(t.en) DESC) AS len_rank
 FROM terms t
 ORDER BY len_rank, t.en
 LIMIT 20;',
'Window: rank terms by length',
'Оконная: ранжировать термины по длине'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE
SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

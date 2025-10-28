/***************************************************
 *  File:       db/seeds/20251028000070_sql_select_subqueries_case_cte.sql
 *  Purpose:    Extend SELECT with subqueries, CASE, and CTE/recursive examples
 *              Convention: examples.title = snippet, descr_* = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Ensure/refresh SELECT command description (UPSERT)
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'SELECT',
       'Retrieve rows; joins, filtering, grouping (HAVING), window/CTE/subqueries.',
       'Извлекать строки; соединения, фильтрация, группировка (HAVING), окна/CTE/подзапросы.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Subqueries
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en FROM terms WHERE length(en) > (SELECT AVG(length(en)) FROM terms);',
       'Subquery: longer than average',
       'Подзапрос: длиннее среднего'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT c.name_en FROM categories c WHERE EXISTS (SELECT 1 FROM terms t WHERE t.category_id = c.id AND t.deleted_on IS NULL);',
       'EXISTS: categories having active terms',
       'EXISTS: категории с активными терминами'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT c.name_en FROM categories c WHERE NOT EXISTS (SELECT 1 FROM terms t WHERE t.category_id = c.id);',
       'NOT EXISTS: categories without any terms',
       'NOT EXISTS: категории без терминов'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en FROM terms WHERE category_id IN (SELECT id FROM categories WHERE name_en IN (''sql'',''shell''));',
       'IN with subquery: SQL or Shell terms',
       'IN с подзапросом: термины SQL или Shell'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- CASE
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en, CASE WHEN ru IS NULL OR trim(ru) = '''' THEN ''—'' ELSE ru END AS ru_display FROM terms LIMIT 10;',
       'CASE: fallback placeholder when RU is blank',
       'CASE: плейсхолдер, если RU пусто'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en, CASE WHEN length(en) <= 3 THEN ''short'' WHEN length(en) <= 6 THEN ''medium'' ELSE ''long'' END AS len_bucket FROM terms ORDER BY length(en) DESC LIMIT 10;',
       'CASE: bucket by length',
       'CASE: классификация по длине'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT c.name_en, SUM(CASE WHEN t.deleted_on IS NULL THEN 1 ELSE 0 END) AS active, SUM(CASE WHEN t.deleted_on IS NOT NULL THEN 1 ELSE 0 END) AS inactive FROM categories c LEFT JOIN terms t ON t.category_id = c.id GROUP BY c.id ORDER BY active DESC, c.name_en;',
       'CASE in aggregates: active vs inactive',
       'CASE в агрегатах: активные vs неактивные'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- CTEs
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'WITH term_counts AS (SELECT category_id, COUNT(*) AS cnt FROM terms GROUP BY category_id) SELECT c.name_en, COALESCE(tc.cnt, 0) AS cnt FROM categories c LEFT JOIN term_counts tc ON tc.category_id = c.id ORDER BY cnt DESC, c.name_en;',
       'CTE: reuse aggregated result',
       'CTE: повторное использование агрегата'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'WITH RECURSIVE seq(x) AS (VALUES(1) UNION ALL SELECT x+1 FROM seq WHERE x < 10) SELECT x FROM seq;',
       'Recursive CTE: generate sequence 1..10',
       'Рекурсивный CTE: последовательность 1..10'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'WITH active_terms AS (SELECT category_id, COUNT(*) AS cnt FROM terms WHERE deleted_on IS NULL GROUP BY category_id) SELECT c.name_en, COALESCE(a.cnt, 0) AS active_terms FROM categories c LEFT JOIN active_terms a ON a.category_id = c.id ORDER BY active_terms DESC, c.name_en;',
       'CTE: active term count per category',
       'CTE: число активных терминов по категории'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

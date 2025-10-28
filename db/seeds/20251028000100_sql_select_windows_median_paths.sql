/***************************************************
 *  File:       db/seeds/20251028000100_sql_select_windows_median_paths.sql
 *  Purpose:    Extend SELECT with window RANGE vs ROWS, median, path aggs
 *              Convention: examples.title = snippet, descr_* = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Ensure/refresh SELECT command description (UPSERT)
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'SELECT',
       'Retrieve rows; joins, filters, grouping (HAVING), windows/CTEs/subqueries.',
       'Извлекать строки; соединения, фильтры, группировка (HAVING), окна/CTE/подзапросы.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- RANGE vs ROWS with ties
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT en,
        LENGTH(en) AS len,
        SUM(1) OVER (ORDER BY LENGTH(en)
                     RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_range,
        SUM(1) OVER (ORDER BY LENGTH(en)
                     ROWS  BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rows
 FROM terms
 WHERE deleted_on IS NULL
 ORDER BY len, en
 LIMIT 20;',
'RANGE vs ROWS with ties (cumulative count)',
'RANGE против ROWS при совпадениях (накопительный счётчик)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Median via extension (quantile)
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'SELECT load_extension(''/opt/homebrew/lib/sqlean/stats'');
 SELECT quantile(LENGTH(en), 0.5) AS median_len FROM terms WHERE deleted_on IS NULL;',
'Median length via sqlean stats.quantile (P50)',
'Медиана длины через sqlean stats.quantile (P50)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Portable median (window-based)
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'WITH s AS (
   SELECT LENGTH(en) AS len,
          ROW_NUMBER() OVER (ORDER BY LENGTH(en)) AS rn,
          COUNT(*)     OVER ()                      AS n
   FROM terms
   WHERE deleted_on IS NULL
 )
 SELECT AVG(len) AS median_len
 FROM s
 WHERE rn IN ((n+1)/2, (n+2)/2);',
'Portable median via row_number + count',
'Портативная медиана через row_number + count'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Recursive path aggregations: leaf paths
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'WITH RECURSIVE nodes(name,parent) AS (
   VALUES (''/'',NULL),(''/usr'',''/''),(''/usr/bin'',''/usr''),(''/usr/local'',''/usr''),
          (''/var'',''/''),(''/var/log'',''/var'')
 ),
 paths(name, depth, path) AS (
   SELECT name, 0 AS depth, name AS path
   FROM nodes WHERE parent IS NULL
   UNION ALL
   SELECT n.name, p.depth+1, p.path || '' -> '' || n.name
   FROM nodes n
   JOIN paths p ON n.parent = p.name
 )
 SELECT path, depth
 FROM paths
 WHERE name NOT IN (SELECT parent FROM nodes WHERE parent IS NOT NULL)
 ORDER BY depth DESC, path;',
'Recursive path aggregation: list leaf paths with depth',
'Рекурсивная агрегация пути: листовые пути с глубиной'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Recursive path aggregations: longest path(s)
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
'WITH RECURSIVE nodes(name,parent) AS (
   VALUES (''/'',NULL),(''/usr'',''/''),(''/usr/bin'',''/usr''),(''/usr/local'',''/usr''),
          (''/var'',''/''),(''/var/log'',''/var'')
 ),
 paths(name, depth, path) AS (
   SELECT name, 0, name FROM nodes WHERE parent IS NULL
   UNION ALL
   SELECT n.name, p.depth+1, p.path || '' -> '' || n.name
   FROM nodes n JOIN paths p ON n.parent = p.name
 ),
 ranked AS (
   SELECT path, depth, RANK() OVER (ORDER BY depth DESC) AS rnk FROM paths
 )
 SELECT path, depth
 FROM ranked
 WHERE rnk = 1
 ORDER BY path;',
'Recursive path aggregation: longest path(s)',
'Рекурсивная агрегация пути: самый длинный путь(и)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

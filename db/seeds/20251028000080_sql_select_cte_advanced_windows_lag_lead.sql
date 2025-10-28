/***************************************************
 *  File:       db/seeds/20251028000080_sql_select_cte_advanced_windows_lag_lead.sql
 *  Purpose:    Extend SELECT with advanced CTEs (recursive), running totals, LAG/LEAD
 *              Convention: examples.title = snippet, descr_* = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Ensure/refresh SELECT command description (UPSERT)
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'SELECT',
       'Retrieve rows; joins, filtering, grouping (HAVING), windows/CTEs/subqueries.',
       'Извлекать строки; соединения, фильтрация, группировка (HAVING), окна/CTE/подзапросы.'
FROM categories c WHERE c.name_en='sql'
ON CONFLICT(category_id, title)
DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Running totals by day
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'WITH daily AS (SELECT date(created_at) AS d, COUNT(*) AS cnt FROM terms WHERE deleted_on IS NULL GROUP BY d) SELECT d, cnt, SUM(cnt) OVER (ORDER BY d) AS running_total FROM daily ORDER BY d;',
       'Running total by day (SUM OVER ORDER BY)',
       'Накопительный итог по дням (SUM OVER ORDER BY)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Running totals per category (row frame)
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'SELECT c.name_en, t.en, SUM(1) OVER (PARTITION BY c.name_en ORDER BY t.en ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_ct FROM terms t JOIN categories c ON c.id = t.category_id ORDER BY c.name_en, t.en LIMIT 50;',
       'Running count within each category',
       'Накопительный счётчик в каждой категории'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- LAG: compare to previous
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'SELECT t.en, LENGTH(t.en) AS len, LAG(LENGTH(t.en)) OVER (ORDER BY t.en) AS prev_len, (LENGTH(t.en) - LAG(LENGTH(t.en)) OVER (ORDER BY t.en)) AS diff FROM terms t ORDER BY t.en LIMIT 20;',
       'LAG: compare to previous row',
       'LAG: сравнить с предыдущей строкой'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- LEAD: time gap
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'SELECT t.en, t.created_at, LEAD(t.created_at) OVER (ORDER BY t.created_at) AS next_created_at, CAST((julianday(LEAD(t.created_at) OVER (ORDER BY t.created_at)) - julianday(t.created_at)) * 86400 AS INTEGER) AS secs_to_next FROM terms t ORDER BY t.created_at LIMIT 20;',
       'LEAD: time gap to next row (seconds)',
       'LEAD: интервал до следующей строки (сек)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- LAG/LEAD partitioned by category
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'SELECT c.name_en, t.en, LAG(t.en) OVER (PARTITION BY c.name_en ORDER BY t.en) AS prev_in_cat, LEAD(t.en) OVER (PARTITION BY c.name_en ORDER BY t.en) AS next_in_cat FROM terms t JOIN categories c ON c.id = t.category_id ORDER BY c.name_en, t.en LIMIT 30;',
       'LAG/LEAD within category',
       'LAG/LEAD внутри категории'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Recursive CTE: hierarchy from VALUES
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'WITH RECURSIVE nodes(name,parent) AS (VALUES (''/'',NULL),(''/usr'',''/''),(''/usr/bin'',''/usr''),(''/usr/local'',''/usr''),(''/var'',''/''),(''/var/log'',''/var'')), tree(name,parent,depth,path) AS (SELECT name,parent,0,name FROM nodes WHERE parent IS NULL UNION ALL SELECT n.name,n.parent,tree.depth+1,tree.path || '' -> '' || n.name FROM nodes n JOIN tree ON n.parent = tree.name) SELECT name, depth, path FROM tree ORDER BY depth, name;',
       'Recursive CTE: hierarchy traversal (VALUES)',
       'Рекурсивный CTE: обход иерархии (VALUES)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Recursive CTE: transitive closure on tiny DAG
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id,
       'WITH RECURSIVE edges(child,parent) AS (VALUES (''SELECT'',NULL),(''JOIN'',''SELECT''),(''HAVING'',''SELECT''),(''WINDOW'',''SELECT''),(''LAG'',''WINDOW'')), closure(child,ancestor) AS (SELECT child,parent FROM edges WHERE parent IS NOT NULL UNION ALL SELECT c.child, e.parent FROM closure c JOIN edges e ON c.ancestor = e.child WHERE e.parent IS NOT NULL) SELECT child, GROUP_CONCAT(ancestor, '' -> '') AS ancestry FROM closure GROUP BY child ORDER BY child;',
       'Recursive CTE: ancestry (transitive closure)',
       'Рекурсивный CTE: предки (транзитивное замыкание)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

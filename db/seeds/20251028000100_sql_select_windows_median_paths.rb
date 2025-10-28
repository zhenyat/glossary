################################################################################
#   File:     db/seeds/20251028000100_sql_select_windows_median_paths.rb
#   Purpose:  Extend SELECT with window RANGE vs ROWS gotchas, median, path aggs
#             Convention: examples.title = snippet, descr_* = phrase
#
#       Window frame RANGE vs ROWS gotchas with ties
#       Medians (via quantile extension and a portable window-function method)
#       Recursive path aggregations (leaf paths, longest paths)
#   Notes
#       RANGE vs ROWS gotcha: With ORDER BY LENGTH(en), RANGE includes all peers
#       with the same length at once; ROWS counts row-by-row. 
#       You’ll see cum_range stay flat across ties and jump at the boundary, 
#       while cum_rows increases each row.
#
#       Median via quantile requires the sqlean stats extension. 
#       Path may differ on your Mac. If extension loading is disabled, 
#       use the portable window-based median instead.
#
#       Recursive path aggs operate on an inline toy hierarchy (VALUES). 
#       Swap in your own edges/nodes when you teach graph topics.
#
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
  descr_en: "Retrieve rows; joins, filters, grouping (HAVING), windows/CTEs/subqueries.",
  descr_ru: "Извлекать строки; соединения, фильтры, группировка (HAVING), окна/CTE/подзапросы."
)

examples = [
  # RANGE vs ROWS gotchas with ties
  [
    "SELECT en,
            LENGTH(en) AS len,
            SUM(1) OVER (ORDER BY LENGTH(en)
                         RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_range,
            SUM(1) OVER (ORDER BY LENGTH(en)
                         ROWS  BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rows
     FROM terms
     WHERE deleted_on IS NULL
     ORDER BY len, en
     LIMIT 20;",
    "RANGE vs ROWS with ties (cumulative count)",
    "RANGE против ROWS при совпадениях (накопительный счётчик)"
  ],
  # Median via extension (quantile) and portable window-based median
  [
    "SELECT load_extension('/opt/homebrew/lib/sqlean/stats');
     SELECT quantile(LENGTH(en), 0.5) AS median_len FROM terms WHERE deleted_on IS NULL;",
    "Median length via sqlean stats.quantile (P50)",
    "Медиана длины через sqlean stats.quantile (P50)"
  ],
  [
    "WITH s AS (
       SELECT LENGTH(en) AS len,
              ROW_NUMBER() OVER (ORDER BY LENGTH(en)) AS rn,
              COUNT(*)     OVER ()                      AS n
       FROM terms
       WHERE deleted_on IS NULL
     )
     SELECT AVG(len) AS median_len
     FROM s
     WHERE rn IN ((n+1)/2, (n+2)/2);",
    "Portable median via row_number + count",
    "Портативная медиана через row_number + count"
  ],
  # Recursive path aggregations (leaf paths and deepest path)
  [
    "WITH RECURSIVE nodes(name,parent) AS (
       VALUES ('/',NULL),('/usr','/'),('/usr/bin','/usr'),('/usr/local','/usr'),
              ('/var','/'),('/var/log','/var')
     ),
     paths(name, depth, path) AS (
       SELECT name, 0 AS depth, name AS path
       FROM nodes WHERE parent IS NULL
       UNION ALL
       SELECT n.name, p.depth+1, p.path || ' -> ' || n.name
       FROM nodes n
       JOIN paths p ON n.parent = p.name
     )
     SELECT path, depth
     FROM paths
     WHERE name NOT IN (SELECT parent FROM nodes WHERE parent IS NOT NULL)
     ORDER BY depth DESC, path;",
    "Recursive path aggregation: list leaf paths with depth",
    "Рекурсивная агрегация пути: листовые пути с глубиной"
  ],
  [
    "WITH RECURSIVE nodes(name,parent) AS (
       VALUES ('/',NULL),('/usr','/'),('/usr/bin','/usr'),('/usr/local','/usr'),
              ('/var','/'),('/var/log','/var')
     ),
     paths(name, depth, path) AS (
       SELECT name, 0, name FROM nodes WHERE parent IS NULL
       UNION ALL
       SELECT n.name, p.depth+1, p.path || ' -> ' || n.name
       FROM nodes n JOIN paths p ON n.parent = p.name
     ),
     ranked AS (
       SELECT path, depth,
              RANK() OVER (ORDER BY depth DESC) AS rnk
       FROM paths
     )
     SELECT path, depth
     FROM ranked
     WHERE rnk = 1
     ORDER BY path;",
    "Recursive path aggregation: longest path(s)",
    "Рекурсивная агрегация пути: самый длинный путь(и)"
  ]
]

examples.each do |snippet, phr_en, phr_ru|
  upsert_example!(command: select_cmd, snippet: snippet, phrase_en: phr_en, phrase_ru: phr_ru)
end

################################################################################
#   File:     db/seeds/20251028000090_sql_select_windows_percentiles_bfs_dfs.rb
#   Purpose:  Extend SELECT with window frames, percentiles, recursive BFS/DFS
#             Convention: examples.title = snippet, descr_* = phrase
#
#     Window frame variants (moving averages, ROWS vs RANGE, centered windows)
#     Percentiles via extension (sqlean stats/quantile) + built-in approximations
#     Recursive BFS/DFS-style traversals with CTEs
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
  descr_en: "Retrieve rows; joins, filtering, grouping (HAVING), windows/CTEs/subqueries.",
  descr_ru: "Извлекать строки; соединения, фильтрация, группировка (HAVING), окна/CTE/подзапросы."
)

examples = [
  # Window frame variants
  [
    "WITH daily AS (
       SELECT date(created_at) AS d, COUNT(*) AS cnt
       FROM terms WHERE deleted_on IS NULL GROUP BY d
     )
     SELECT d, cnt,
            AVG(cnt) OVER (ORDER BY d
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS mov_avg_3d
     FROM daily ORDER BY d;",
    "Moving average (3-day, trailing)",
    "Скользящее среднее за 3 дня (хвостовое)"
  ],
  [
    "SELECT en, LENGTH(en) AS len,
            SUM(1) OVER (ORDER BY len
                         RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_by_len
     FROM terms ORDER BY len, en LIMIT 20;",
    "RANGE vs ROWS: cumulative by numeric value",
    "RANGE против ROWS: накопление по значению"
  ],
  [
    "SELECT c.name_en, t.en,
            COUNT(*) OVER (PARTITION BY c.name_en ORDER BY t.en
                           ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING) AS window_7
     FROM terms t JOIN categories c ON c.id = t.category_id
     ORDER BY c.name_en, t.en LIMIT 30;",
    "Centered 7-row window per category",
    "Симметричное окно на 7 строк в категории"
  ],

  # Percentiles via extension + built-in approximations
  [
    "SELECT load_extension('/opt/homebrew/lib/sqlean/stats');
     SELECT quantile(LENGTH(en), 0.9) AS p90_len FROM terms;",
    "Percentile (P90) via sqlean stats.quantile (extension)",
    "Персентиль (P90) через расширение sqlean stats.quantile"
  ],
  [
    "SELECT len FROM (
       SELECT LENGTH(en) AS len,
              CUME_DIST() OVER (ORDER BY LENGTH(en)) AS cd
       FROM terms
     ) WHERE cd >= 0.9
     ORDER BY cd, len LIMIT 1;",
    "Approximate P90 using CUME_DIST",
    "Приблизительный P90 через CUME_DIST"
  ],
  [
    "SELECT len FROM (
       SELECT LENGTH(en) AS len,
              PERCENT_RANK() OVER (ORDER BY LENGTH(en)) AS pr
       FROM terms
     ) WHERE pr >= 0.9
     ORDER BY pr, len LIMIT 1;",
    "Approximate P90 using PERCENT_RANK",
    "Приблизительный P90 через PERCENT_RANK"
  ],

  # Recursive BFS/DFS patterns (on an inline tiny graph)
  [
    "WITH RECURSIVE edges(p, c) AS (
        VALUES ('SELECT',NULL), ('JOIN','SELECT'), ('HAVING','SELECT'),
               ('WINDOW','SELECT'), ('LAG','WINDOW'), ('LEAD','WINDOW')
     ),
     bfs(node, depth, path) AS (
       SELECT 'SELECT', 0, 'SELECT'
       UNION ALL
       SELECT e.c, bfs.depth+1, bfs.path || ' -> ' || e.c
       FROM edges e JOIN bfs ON e.p = bfs.node
       WHERE e.c IS NOT NULL
     )
     SELECT node, depth, path FROM bfs
     ORDER BY depth, node;",
    "Recursive CTE: BFS-style order by depth",
    "Рекурсивный CTE: порядок обхода в стиле BFS (по глубине)"
  ],
  [
    "WITH RECURSIVE edges(p, c) AS (
        VALUES ('SELECT',NULL), ('JOIN','SELECT'), ('HAVING','SELECT'),
               ('WINDOW','SELECT'), ('LAG','WINDOW'), ('LEAD','WINDOW')
     ),
     dfs(node, path) AS (
       SELECT 'SELECT', 'SELECT'
       UNION ALL
       SELECT e.c, dfs.path || ' -> ' || e.c
       FROM edges e JOIN dfs ON e.p = dfs.node
       WHERE e.c IS NOT NULL
     )
     SELECT node, path FROM dfs
     ORDER BY path;",
    "Recursive CTE: DFS-style lexical path order",
    "Рекурсивный CTE: стиль DFS с лексикографическим порядком пути"
  ]
]

examples.each do |snippet, phr_en, phr_ru|
  upsert_example!(command: select_cmd, snippet: snippet, phrase_en: phr_en, phrase_ru: phr_ru)
end

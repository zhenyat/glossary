################################################################################
#   File:     db/seeds/20251028000080_sql_select_cte_advanced_windows_lag_lead.rb
#   Purpose:  Extend SELECT with advanced CTEs (recursive), running totals, LAG/LEAD
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
  descr_en: "Retrieve rows; joins, filtering, grouping (HAVING), windows/CTEs/subqueries.",
  descr_ru: "Извлекать строки; соединения, фильтрация, группировка (HAVING), окна/CTE/подзапросы."
)

examples = [
  # Running totals by day
  [
    "WITH daily AS (SELECT date(created_at) AS d, COUNT(*) AS cnt FROM terms WHERE deleted_on IS NULL GROUP BY d) SELECT d, cnt, SUM(cnt) OVER (ORDER BY d) AS running_total FROM daily ORDER BY d;",
    "Running total by day (SUM OVER ORDER BY)",
    "Накопительный итог по дням (SUM OVER ORDER BY)"
  ],
  # Running totals per category (row-based frame)
  [
    "SELECT c.name_en, t.en, SUM(1) OVER (PARTITION BY c.name_en ORDER BY t.en ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_ct FROM terms t JOIN categories c ON c.id = t.category_id ORDER BY c.name_en, t.en LIMIT 50;",
    "Running count within each category",
    "Накопительный счётчик в каждой категории"
  ],
  # LAG: previous length and diff
  [
    "SELECT t.en, LENGTH(t.en) AS len, LAG(LENGTH(t.en)) OVER (ORDER BY t.en) AS prev_len, (LENGTH(t.en) - LAG(LENGTH(t.en)) OVER (ORDER BY t.en)) AS diff FROM terms t ORDER BY t.en LIMIT 20;",
    "LAG: compare to previous row",
    "LAG: сравнить с предыдущей строкой"
  ],
  # LEAD: time to next term (seconds)
  [
    "SELECT t.en, t.created_at, LEAD(t.created_at) OVER (ORDER BY t.created_at) AS next_created_at, CAST((julianday(LEAD(t.created_at) OVER (ORDER BY t.created_at)) - julianday(t.created_at)) * 86400 AS INTEGER) AS secs_to_next FROM terms t ORDER BY t.created_at LIMIT 20;",
    "LEAD: time gap to next row (seconds)",
    "LEAD: интервал до следующей строки (сек)"
  ],
  # LAG/LEAD by partition (category)
  [
    "SELECT c.name_en, t.en, LAG(t.en) OVER (PARTITION BY c.name_en ORDER BY t.en) AS prev_in_cat, LEAD(t.en) OVER (PARTITION BY c.name_en ORDER BY t.en) AS next_in_cat FROM terms t JOIN categories c ON c.id = t.category_id ORDER BY c.name_en, t.en LIMIT 30;",
    "LAG/LEAD within category",
    "LAG/LEAD внутри категории"
  ],
  # Recursive CTE: simple filesystem-like hierarchy from VALUES
  [
    "WITH RECURSIVE nodes(name,parent) AS (VALUES ('/',NULL),('/usr','/'),('/usr/bin','/usr'),('/usr/local','/usr'),('/var','/'),('/var/log','/var')), tree(name,parent,depth,path) AS (SELECT name,parent,0,name FROM nodes WHERE parent IS NULL UNION ALL SELECT n.name,n.parent,tree.depth+1,tree.path || ' -> ' || n.name FROM nodes n JOIN tree ON n.parent = tree.name) SELECT name, depth, path FROM tree ORDER BY depth, name;",
    "Recursive CTE: hierarchy traversal (VALUES)",
    "Рекурсивный CTE: обход иерархии (VALUES)"
  ],
  # Recursive CTE: transitive closure on a tiny DAG (prerequisites)
  [
    "WITH RECURSIVE edges(child,parent) AS (VALUES ('SELECT',NULL),('JOIN','SELECT'),('HAVING','SELECT'),('WINDOW','SELECT'),('LAG','WINDOW')), closure(child,ancestor) AS (SELECT child,parent FROM edges WHERE parent IS NOT NULL UNION ALL SELECT c.child, e.parent FROM closure c JOIN edges e ON c.ancestor = e.child WHERE e.parent IS NOT NULL) SELECT child, GROUP_CONCAT(ancestor, ' -> ') AS ancestry FROM closure GROUP BY child ORDER BY child;",
    "Recursive CTE: ancestry (transitive closure)",
    "Рекурсивный CTE: предки (транзитивное замыкание)"
  ]
]

examples.each do |snippet, phr_en, phr_ru|
  upsert_example!(command: select_cmd, snippet: snippet, phrase_en: phr_en, phrase_ru: phr_ru)
end

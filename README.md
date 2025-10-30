# Glossary App (EN/RU) — SQLite + ActiveRecord + Sinatra

A bilingual glossary and command examples app designed for teaching Russian-speaking novices. It uses a clean SQLite schema, Ruby ActiveRecord migrations, soft deletes (deleted_on), and FTS5 for fast full‑text search, plus a lightweight Sinatra web UI for CRUD and search.

What’s new
- Default DB name: `glossary.sqlite3`
- Examples convention: `examples.title` contains the command snippet; `examples.descr_en` contains the human‑readable phrase (EN), `examples.descr_ru` (RU)
- Added seeds:
  - Shell/Unix commands (uname, whoami, pwd, cd, mkdir, rmdir, rm, mv, touch, cat, head, tail)
  - SQL commands and examples (SELECT/INSERT/UPDATE; JOIN/HAVING/windows; subqueries/CASE/CTE; LAG/LEAD; window frames; percentiles; recursive BFS/DFS; medians; path aggregations)
  - Git commands (clone/commit/push/branch/log)
- Initial Sinatra web UI (Terms): FTS search, category filter, pagination, CRUD, soft‑delete/restore
- Web UI extension: Commands and nested Examples, with “Show deleted” toggles across Terms/Commands/Examples


## Highlights

- Tables: categories, terms, commands, examples (+ FTS5 index: terms_fts)
- Soft delete via `deleted_on` (no destructive cascades by default)
- FKs: RESTRICT on categories → terms/commands; CASCADE on commands → examples
- Partial unique indexes scoped to active rows (`deleted_on IS NULL`)
- FTS5 (unicode61) indexing `terms` for EN/RU search
- Two setup paths: zsh (raw SQL) or Ruby (migrations + seeds)
- Sinatra web UI (Terms, Commands, Examples) with “Show deleted” toggle
- Header banner on all code files


## Prerequisites

- `macOS` Sonoma or later
- `SQLite` 3.50.4+ with FTS5 enabled  
  Check:
    ```
    sqlite3 -line ":memory:" "SELECT sqlite_compileoption_used('ENABLE_FTS5') AS fts5;"
    ```
  Should print `fts5 = 1`

- `Ruby 3.4.7`
- `Gems` (managed via Gemfile):
- `sinatra ~> 3.2`, `sinatra-contrib ~> 3.2`
- `rack ~> 2.2` (Sinatra 3.x requires Rack 2.x; pin Rack 2.x)
- `puma ~> 6.4` (server)
- `activerecord ~> 8.1`, `sqlite3 >= 1.7`


## Quick start

You have two equivalent ways to set up the database. Choose one per DB file (don’t mix).

### Option A) zsh (raw SQL from ./sql)

1) Create/reset the DB (and seed categories):
    ```
    mkdir -p ./data
    chmod +x scripts/sql_setup.zsh
    ./scripts/sql_setup.zsh --db ./data/glossary.sqlite3 --rebuild
    ```

2) Load full content (terms, commands, examples):
    ```
    sqlite3 ./data/glossary.sqlite3 < db/seeds/20251024000010_terms_commands_examples.sql
    -- Then any additional seed SQLs from the list below
    ```

3) Inspect:
    ```
    sqlite3 ./data/glossary.sqlite3 ".tables"
    ```

  Notes:
  - The zsh script reads schema SQL from `./sql` and seeds only categories by default (`db/seeds/20251023000000_categories.sql`).<br> 
    Run the consolidated seed and any topic-specific seeds to populate all content.

### Option B) Ruby (migrations + seeds; Rails‑less runner)

1) Install gems:
    ```
    bundle install
    ```

2) Run full reset (migrate + seed all Ruby seeds):
    ```
    DB_PATH=./data/glossary.sqlite3 ruby scripts/ar_setup.rb reset
    ```

3) Inspect:
    ```
    sqlite3 ./data/glossary.sqlite3 ".tables"
    ```

    Other commands:
    - Migrate only: `DB_PATH=./data/glossary.sqlite3 ruby scripts/ar_setup.rb migrate`
    - Seed only: `DB_PATH=./data/glossary.sqlite3 ruby scripts/ar_setup.rb seed`
    - Status: `DB_PATH=./data/glossary.sqlite3 ruby scripts/ar_setup.rb status`

    The AR runner:
    - Loads `db/migrate/*.rb` and calls `migrate(:up)` in order
    - Records versions in `schema_migrations` via simple SQL (no Rails internals)
    - Loads all Ruby seeds from `db/seeds/*.rb` in filename order


## Start the web UI (Sinatra)

1) Ensure gems are installed and Rack is pinned to 2.x (in Gemfile):
      ```
      bundle install
      ```

2) Run (Puma server):
      ```
      DB_PATH=./data/glossary.sqlite3 bundle exec rackup -s puma -p 9292
      ```

3) Open:
- http://127.0.0.1:9292 (redirects to /terms)
- http://127.0.0.1:9292/terms (FTS search / filter / pagination / CRUD)
- http://127.0.0.1:9292/commands (filter / pagination / CRUD)
- http://127.0.0.1:9292/commands/:id (command details with nested examples)

  Features:
  - Terms: FTS search (MATCH), category filter, pagination, create/edit, soft‑delete/restore, “Show deleted”
  - Commands: category filter, pagination, create/edit, soft‑delete/restore, “Show deleted”
  - Examples: nested under a Command; create/edit, soft‑delete/restore, “Show deleted”


## Schema overview

Tables
- `categories`
  - `id`, `name_en` (unique among active), `name_ru`
  - `created_at`, `updated_at`, `deleted_on`
- `terms`
  - `id`, `category_id` (FK→categories RESTRICT), `en`, `abbr_en`, `ru`, `abbr_ru`, `descr_en`, `descr_ru`
  - `created_at`, `updated_at`, `deleted_on`
  - Unique among active: `(category_id, en)`
- `commands`
  - `id`, `category_id` (FK→categories RESTRICT), `title`, `descr_en`, `descr_ru`
  - `created_at`, `updated_at`, `deleted_on`
  - Unique among active: `(category_id, title)`
- `examples`
  - `id`, `command_id` (FK→commands CASCADE), `title` (snippet), `descr_en` (phrase EN), `descr_ru` (phrase RU)
  - `created_at`, `updated_at`, `deleted_on`
  - Unique among active: `(command_id, title)`

Full‑Text Search
- `terms_fts` (FTS5, external‑content for `terms` with `content_rowid=id`)
- Triggers keep it synced on insert/update/delete
- Only active `terms` are indexed (`deleted_on IS NULL`)


## Seeded categories

`name_en` → `name_ru`
- `common` → Общая лексика
- `it-general` → ИТ (общее)
- `programming` → Программирование
- `unix` → Unix/Linux
- `shell` → Командная оболочка
- `git` → Git
- `rdbms` → Реляционные СУБД
- `sql` → SQL
- `sqlite` → SQLite
- `mysql` → MySQL
- `postgresql` → PostgreSQL
- `python` → Python
- `ruby` → Ruby
- `rails` → Ruby on Rails
- `javascript` → JavaScript
- `data-formats` → Форматы данных
- `finance` → Финансы

Seeds
- Categories (kept as‑is):
  - `db/seeds/20251023000000_categories.rb`
  - `db/seeds/20251023000000_categories.sql`
- Consolidated base content (terms, commands, examples):
  - `db/seeds/20251024000010_terms_commands_examples.rb`
  - `db/seeds/20251024000010_terms_commands_examples.sql`
- Shell/Unix commands:
  - `db/seeds/20251028000040_shell_core_commands.{rb,sql}`
- SQL commands and examples:
  - `db/seeds/20251028000050_sql_select_insert_update.{rb,sql}`
  - `db/seeds/20251028000060_sql_select_joins_having_windows.{rb,sql}`
  - `db/seeds/20251028000070_sql_select_subqueries_case_cte.{rb,sql}`
  - `db/seeds/20251028000080_sql_select_cte_advanced_windows_lag_lead.{rb,sql}`
  - `db/seeds/20251028000090_sql_select_windows_percentiles_bfs_dfs.{rb,sql}`
  - `db/seeds/20251028000100_sql_select_windows_median_paths.{rb,sql}`
- Git commands:
  - `db/seeds/20251028000110_git_core_commands.{rb,sql}`


## Searching with FTS5

Do not alias the FTS table on the left of MATCH. Use the table name.

- Basic search:
    ```
    SELECT t.id, t.en, t.ru
    FROM terms t
    JOIN terms_fts ON terms_fts.rowid = t.id
    WHERE t.deleted_on IS NULL
    AND terms_fts MATCH 'json OR yaml'
    ORDER BY bm25(terms_fts)
    LIMIT 10;
    ```

- With highlighting and category:
    ```
    SELECT c.name_en AS category,
    t.en,
    highlight(terms_fts, 0, '[', ']') AS en_hl,
    highlight(terms_fts, 1, '[', ']') AS ru_hl,
    bm25(terms_fts) AS rank
    FROM terms_fts
    JOIN terms t ON terms_fts.rowid = t.id
    JOIN categories c ON c.id = t.category_id
    WHERE t.deleted_on IS NULL
    AND terms_fts MATCH 'json OR yaml'
    ORDER BY rank
    LIMIT 10;
    ```

- Rebuild index (rarely needed):
    ```
    INSERT INTO terms_fts(terms_fts) VALUES('rebuild');
    ```


## Helper scripts

### 1) Search CLI (scripts/search.rb)

Run ranked FTS searches from the terminal, with optional category filter and limit.

Usage:
  ```
  DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb "json OR yaml"
  DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb -c sql "join"
  DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb -l 5 "json*"
  ```

What the samples do:
- `"json OR yaml"` searches the FTS index for either token; results show bm25 rank and highlights.
- `"-c sql 'join'"` restricts to the SQL category and finds JOIN.
- `"-l 5 'json*'"` enables prefix search.

Notes:
- The script quotes your query internally; pass the query as a single shell argument (use single quotes in zsh/bash).
- The search is against `terms_fts`; only active terms are indexed.

### 2) Interactive Console (scripts/console.rb)

Open IRB with ActiveRecord connected, models loaded, and handy helpers.

Launch:
  ```
  DB_PATH=./data/glossary.sqlite3 ruby scripts/console.rb
  ```

Inside the console, use:
- `help` — lists helpers
- `tables` — tables/views list (excluding SQLite internals)
- `schema('terms')` — prints CREATE DDL
- `sql('SELECT count(*) AS cnt FROM terms')` — run raw SQL
- `fts('json OR yaml')` — FTS search with ranking/highlights
- `fts('join', category: 'sql', limit: 5)` — FTS search scoped to a category
- `reload!` — reload models without restarting


## Optional triggers for updated_at

Keep `updated_at` current when modifying rows via raw SQL.

File:  `sql/triggers_update_updated_at.sql`

Apply:
    ```
    sqlite3 ./data/glossary.sqlite3 < sql/triggers_update_updated_at.sql
    ```


## Web UI overview (Sinatra)

- Terms
  - FTS search (MATCH), category filter, pagination
  - Create/edit
  - Soft‑delete/restore
  - “Show deleted” toggle
- Commands
  - Category filter, pagination
  - Create/edit
  - Soft‑delete/restore
  - “Show deleted” toggle
- Examples
  - Nested under a Command detail page
  - Create/edit
  - Soft‑delete/restore
  - “Show deleted” toggle

Run:
  ```
  DB_PATH=./data/glossary.sqlite3 bundle exec rackup -s puma -p 9292
  ```
Open:
- http://127.0.0.1:9292/terms
- http://127.0.0.1:9292/commands


## Directory layout

- `sql/`
  - `create_categories.sql`
  - `create_terms.sql`
  - `create_commands.sql`
  - `create_examples.sql`
  - `create_terms_fts.sql`
  - `triggers_update_updated_at.sql` (optional)
- `db/`
  - `migrate/`
    - `20251023000001_create_core_tables.rb`
    - `20251023000002_create_terms_fts.rb`
  - `seeds/`
    - `20251023000000_categories.{rb,sql}`
    - `20251024000010_terms_commands_examples.{rb,sql}`
    - `20251028000040_shell_core_commands.{rb,sql}`
    - `20251028000050_sql_select_insert_update.{rb,sql}`
    - `20251028000060_sql_select_joins_having_windows.{rb,sql}`
    - `20251028000070_sql_select_subqueries_case_cte.{rb,sql}`
    - `20251028000080_sql_select_cte_advanced_windows_lag_lead.{rb,sql}`
    - `20251028000090_sql_select_windows_percentiles_bfs_dfs.{rb,sql}`
    - `20251028000100_sql_select_windows_median_paths.{rb,sql}`
    - `20251028000110_git_core_commands.{rb,sql}`
- `app/`
  - `models/`
    - `application_record.rb`
    - `category.rb`
    - `term.rb`
    - `command.rb`
    - `example.rb`
    - `concerns/soft_deletable.rb`
  - `web/`
    - `app.rb` (Sinatra app)
    - `views/` (ERB templates; headers are ERB‑commented to avoid rendering)
      - `layout.erb`
      - `terms/` (index/new/edit/show/_form)
      - `commands/` (index/new/edit/show/_form)
      - `examples/` (new/edit/_form)
- Root:
  - `config.ru`
  - `Gemfile`, `Gemfile.lock` (pin Rack 2.x; use Puma)
- `scripts/`
  - `sql_setup.zsh`  (zsh raw SQL path)
  - `sql_setup.sh`   (POSIX /bin/sh alternative)
  - `ar_setup.rb`    (Rails‑less migration runner + seeds)
  - `search.rb`      (FTS search CLI)
  - `console.rb`     (IRB with AR connected + helpers)


## Development workflow

- Prefer AR migrations as source of truth for schema evolution
- Keep the `./sql` DDL files in sync only if you plan to keep supporting the raw‑SQL setup path
- Soft deletes: set `deleted_on` instead of hard‑deleting; triggers ensure FTS drops inactive terms
- Foreign keys: scripts enable `PRAGMA foreign_keys = ON` per connection


## Troubleshooting

- Rack conflict (Sinatra 3.x requires Rack 2.x)
  - Symptom: “Unable to activate sinatra … rack 3.x conflicts with rack (~> 2.2)”
  - Fix: Pin Rack 2.x in Gemfile, remove Gemfile.lock, `bundle install`, run with `bundle exec`.
- FTS5 unavailable  
  - Symptom: `CREATE VIRTUAL TABLE ... fts5` fails.  
  - Check: `SELECT sqlite_compileoption_used('ENABLE_FTS5');`  
  - Fix (Homebrew): `brew install sqlite` and ensure your PATH uses Homebrew `sqlite3`.
- Raw SQL path seeded only categories  
  - Run the consolidated content seed:
    - `sqlite3 ./data/glossary.sqlite3 < db/seeds/20251024000010_terms_commands_examples.sql`
- AR path avoids fragile internals  
  - The provided `ar_setup.rb` is Rails‑less and records versions directly in `schema_migrations`, avoiding AR 8.x internal API changes.
- Russian collation/uniqueness  
  - `COLLATE NOCASE` is primarily ASCII. For full Cyrillic collation you’d need ICU (advanced; optional).


## License

Choose your preferred license (e.g., MIT). Add a LICENSE file if you plan to share/distribute.

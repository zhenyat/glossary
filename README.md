# Glossary App (EN/RU) — SQLite + ActiveRecord

A bilingual glossary and command examples app designed for teaching Russian-speaking novices. It uses a clean SQLite schema, Ruby ActiveRecord migrations, soft deletes (deleted_on), and FTS5 for fast full‑text search.

What’s new
- Default DB name: `glossary.sqlite3`
- Examples convention: `examples.title` contains the command snippet; `examples.descr_en` contains the human‑readable phrase (EN), `examples.descr_ru` the RU phrase
- Two setup paths supported:
  - Raw SQL via zsh (applies SQL DDL, then category seed; full content seed needs one extra step)
  - Ruby via a Rails‑less migration runner (migrate + seed everything end‑to‑end)


## Highlights

- Tables: categories, terms, commands, examples (+ FTS5 index: terms_fts)
- Soft delete via `deleted_on` (no destructive cascades by default)
- FKs: RESTRICT on categories → terms/commands; CASCADE on commands → examples
- Partial unique indexes scoped to active rows (`deleted_on IS NULL`)
- FTS5 (unicode61) indexing `terms` for EN/RU search
- Two setup paths: zsh (raw SQL) or Ruby (migrations + seeds)
- Header banner on all code files


## Prerequisites

- macOS Sonoma or later
- SQLite 3.50.4+ with FTS5 enabled  
  Check:
    - `sqlite3 -line ":memory:" "SELECT sqlite_compileoption_used('ENABLE_FTS5') AS fts5;"` → should show `fts5 = 1`
- Ruby 3.4.7
  - Gems: `activerecord` (8.x), `sqlite3`
- Optional: VS Code


## Quick start

You have two equivalent ways to set up the database. Choose one per DB file (don’t mix).

### Option A) zsh (raw SQL from ./sql)

1) Create/reset the DB (and seed categories):
    
    mkdir -p ./data
    chmod +x scripts/sql_setup.zsh
    ./scripts/sql_setup.zsh --db ./data/glossary.sqlite3 --rebuild

2) Load full content (terms, commands, examples):
    
    sqlite3 ./data/glossary.sqlite3 < db/seeds/20251024000010_terms_commands_examples.sql

3) Inspect:
    
    sqlite3 ./data/glossary.sqlite3 ".tables"

Notes:
- The zsh script reads schema SQL from `./sql` and seeds only categories by default (`db/seeds/20251023000000_categories.sql`). Run the consolidated seed SQL once to populate all content.

### Option B) Ruby (migrations + seeds; Rails‑less runner)

1) Install gems:
```    
    gem install activerecord sqlite3
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
- Loads migration classes from `db/migrate/*.rb` and calls `migrate(:up)` in order
- Records versions in `schema_migrations` using simple SQL (no Rails internals)
- Loads all Ruby seeds from `db/seeds/*.rb` in filename order


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
- Categories (kept as‑is): `db/seeds/20251023000000_categories.rb` and `.sql`
- Consolidated content (terms, commands, examples): `db/seeds/20251024000010_terms_commands_examples.rb` and `.sql`


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
- Basic:
```  
  DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb "json OR yaml"
```
- Filter by category:
``` 
  DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb -c sql "join"
```
- Prefix search (term starts with …):
```  
  DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb -l 5 "json*"
```
What the samples do:
- "json OR yaml" searches the FTS index for either token. You’ll see results like:
  - [data-formats] rank=-8.061 en: [YAML] ru: [YAML]
  - [data-formats] rank=-3.338 en: [JSON] ru: [JSON]
  Explanation:
  - Rank is bm25 score (lower is better; often negative in SQLite’s bm25).
  - Highlighted tokens are wrapped in [brackets] via highlight(...).

- "-c sql 'join'" restricts results to the SQL category and searches for “join”. It will return the SQL term “JOIN” with highlights.

- "-l 5 'json*'" enables prefix search (tokens starting with json). Note:
  - FTS5 supports '*'-suffix prefix queries. Without FTS prefix indexes, this is fine for small datasets; for very large datasets, consider FTS5 prefix options.

Notes:
- The script quotes your query internally; pass the query as a single shell argument (use single quotes in zsh/bash).
- The search is against the FTS index (terms_fts). Only active terms (deleted_on IS NULL) are indexed.

### 2) Interactive Console (scripts/console.rb)

Open IRB with ActiveRecord connected, models loaded, and handy helpers.

Launch:
```
DB_PATH=./data/glossary.sqlite3 ruby scripts/console.rb
```
Inside the console, use:
- `help`   - Lists available helpers.
- `tables`  - Lists all tables/views (excluding SQLite internals).
- `schema('terms')`  - Prints the CREATE DDL for the given table/view.
- `sql('SELECT count(*) AS cnt FROM terms')`  - Runs raw SQL and returns an array of hashes.
- `fts('json OR yaml')`  - Runs an FTS search over terms with ranking and highlights.
- `fts('join', category: 'sql', limit: 5)`  - FTS search limited to the SQL category, returning top 5.
- `reload!`  - Reloads models (after code changes) without restarting the console.
- `conn`  - ActiveRecord connection

Example session:
```
> help
> tables
> schema('terms')
> sql('SELECT count(*) AS cnt FROM terms')
> fts('json OR yaml')
> fts('join', category: 'sql', limit: 5)
```

You’ll see output similar to the CLI search:
- Each result shows [category], bm25 rank, and highlighted matches for en/ru.

Tip:
- The console enables `PRAGMA foreign_keys = ON` automatically.


## Optional triggers for updated_at

Keep `updated_at` current when modifying rows via raw SQL.

File: `sql/triggers_update_updated_at.sql`

Apply: 
```
sqlite3 ./data/glossary.sqlite3 < sql/triggers_update_updated_at.sql
```

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
    - `20251023000000_categories.rb`
    - `20251023000000_categories.sql`
    - `20251024000010_terms_commands_examples.rb`
    - `20251024000010_terms_commands_examples.sql`
- `app/`
  - `models/`
    - `application_record.rb`
    - `category.rb`
    - `term.rb`
    - `command.rb`
    - `example.rb`
    - `concerns/soft_deletable.rb`
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

- FTS5 unavailable  
  Symptom: `CREATE VIRTUAL TABLE ... fts5` fails.  
  Check: `SELECT sqlite_compileoption_used('ENABLE_FTS5');`  
  Fix (Homebrew): `brew install sqlite` and ensure your PATH uses Homebrew `sqlite3`.

- Raw SQL path seeded only categories  
  Run the consolidated content seed:
    - `sqlite3 ./data/glossary.sqlite3 < db/seeds/20251024000010_terms_commands_examples.sql`

- AR path avoids fragile internals  
  The provided `ar_setup.rb` is Rails‑less and records versions directly in `schema_migrations`, avoiding AR 8.x internal API changes.

- Russian collation/uniqueness  
  `COLLATE NOCASE` is primarily ASCII. For full Cyrillic collation you’d need ICU (advanced; optional).


## License

Choose your preferred license (e.g., MIT). Add a LICENSE file if you plan to share/distribute.

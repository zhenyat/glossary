# Glossary App (EN/RU) — SQLite + ActiveRecord

A bilingual glossary and command examples app designed for teaching Russian-speaking novices. It uses a clean SQLite schema, Ruby ActiveRecord for migrations/models, soft deletes, and FTS5 for fast full-text search over terms.

Note on timestamps: `updated_at` is application-managed. ActiveRecord updates it automatically; if you modify rows via raw SQL, update `updated_at` yourself (or add DB triggers if you want auto-updates at the DB level).

## Highlights

- SQLite schema with categories, terms, commands, examples
- Soft delete via `deleted_on` (keeps history; no destructive cascades)
- Referential integrity with explicit FK actions (RESTRICT/CASCADE)
- FTS5 external-content index on `terms` with sync triggers (active rows only)
- Two setup paths:
  - zsh script applying raw SQL from `./sql`
  - Ruby script running ActiveRecord migrations + Ruby seeds
- Category seeds included (EN/RU)
- All code files include a header banner for clarity and provenance

## Prerequisites

- macOS (Sonoma or later)
- SQLite 3.50.4+ with FTS5 enabled  
  Check:
    - `sqlite3 -line ":memory:" "SELECT sqlite_compileoption_used('ENABLE_FTS5') AS fts5;"` should show `fts5 = 1`
- Ruby 3.4.7
  - Gems: `activerecord` 8.0.3, `sqlite3`
- Optional: VS Code (for dev)

## Quick start

You have two equivalent ways to set up the database. Choose one per DB file (don’t mix).

### Option A) zsh (raw SQL from ./sql)

1) Create the DB (and seed categories):
    
    mkdir -p ./data
    chmod +x scripts/sql_setup.zsh
    ./scripts/sql_setup.zsh --db ./data/glossary.sqlite3 --rebuild

2) Inspect:
    
    sqlite3 ./data/glossary.sqlite3 ".tables"

### Option B) Ruby (ActiveRecord migrations + Ruby seeds)

1) Install gems:
    
    gem install activerecord sqlite3

2) Run migrations and seeds:
    
    DB_PATH=./data/glossary.sqlite3 ruby scripts/ar_setup.rb reset

3) Inspect:
    
    sqlite3 ./data/glossary.sqlite3 ".tables"

Tip: If you switch methods on the same DB file, delete the DB first (use `--rebuild` or `reset`).

## What’s inside (schema overview)

Tables
- `categories`
  - `id`, `name_en` (unique among active), `name_ru`
  - `created_at`, `updated_at`, `deleted_on`
- `terms`
  - `id`, `category_id` (FK→categories, RESTRICT), `en`, `abbr_en`, `ru`, `abbr_ru`, `descr_en`, `descr_ru`
  - `created_at`, `updated_at`, `deleted_on`
  - Uniqueness: `(category_id, en)` among active rows
- `commands`
  - `id`, `category_id` (FK→categories, RESTRICT), `title`, `descr_en`, `descr_ru`
  - `created_at`, `updated_at`, `deleted_on`
  - Uniqueness: `(category_id, title)` among active rows
- `examples`
  - `id`, `command_id` (FK→commands, CASCADE), `title`, `descr_en`, `descr_ru`
  - `created_at`, `updated_at`, `deleted_on`
  - Uniqueness: `(command_id, title)` among active rows

Full‑Text Search
- `terms_fts` (FTS5, external-content on `terms` with `content_rowid = id`)
- Triggers keep it in sync for INSERT/UPDATE/DELETE
- Index stores only active (`deleted_on IS NULL`) terms

## Seed categories

Included categories (`name_en` → `name_ru`):
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

Seeds are provided both as:
- `db/seeds/20251023000000_categories.rb` (ActiveRecord)
- `db/seeds/20251023000000_categories.sql` (sqlite3 CLI)

## Searching with FTS5

- Exact/prefix search:
    
    SELECT t.*
    FROM terms t
    JOIN terms_fts f ON f.rowid = t.id
    WHERE t.deleted_on IS NULL AND f MATCH 'json OR yaml'
    ORDER BY bm25(f)
    LIMIT 20;

- Prefix example:
    
    SELECT t.*
    FROM terms t
    JOIN terms_fts f ON f.rowid = t.id
    WHERE t.deleted_on IS NULL AND f MATCH 'pos*';

- Snippets/highlights:
    
    SELECT highlight(f, 0, '<b>','</b>') AS en_hl
    FROM terms_fts f
    WHERE f MATCH 'join';

- Maintenance:
    
    INSERT INTO terms_fts(terms_fts) VALUES('rebuild');
    INSERT INTO terms_fts(terms_fts) VALUES('optimize');

Tokenizer: `unicode61` is used; it handles Latin and Cyrillic well. There’s no built-in Russian stemming; typically fine for a glossary.

Soft delete interaction: Updating `deleted_on` will remove/add rows from the FTS index via the UPDATE trigger (active rows only are indexed).

## ActiveRecord models and integrity

Associations
- Category `has_many` Terms (restrict on delete)
- Category `has_many` Commands (restrict on delete)
- Command `has_many` Examples (cascade on delete)

Soft deletes
- Term/Command/Example include a `SoftDeletable` concern:
  - `destroy` → soft deletes (sets `deleted_on`)
  - `hard_destroy!` → permanent delete (respecting DB FK actions)

Uniqueness
- Partial unique indexes ensure uniqueness applies only to active rows (`deleted_on IS NULL`)
- English fields use `COLLATE NOCASE`; note that NOCASE doesn’t fully cover Russian collation

## Directory layout

- `sql/`
  - `create_categories.sql`
  - `create_terms.sql`
  - `create_commands.sql`
  - `create_examples.sql`
  - `create_terms_fts.sql`
- `db/`
  - `migrate/`
    - `20251023000001_create_core_tables.rb`
    - `20251023000002_create_terms_fts.rb`
  - `seeds/`
    - `20251023000000_categories.rb`
    - `20251023000000_categories.sql`
- `app/`
  - `models/`
    - `application_record.rb`
    - `category.rb`
    - `term.rb`
    - `command.rb`
    - `example.rb`
    - `concerns/`
      - `soft_deletable.rb`
- `scripts/`
  - `sql_setup.zsh`  (zsh raw SQL)
  - `sql_setup.sh`   (POSIX /bin/sh alternative)
  - `ar_setup.rb`    (ActiveRecord migrations + seeds)

All code files include a header banner (File, Purpose, Author, Date).

## Development workflow

- Prefer the ActiveRecord migrations as the source of truth for schema changes.
- Keep SQL DDL files in sync if you intend to support the raw-SQL path.
- When updating records via raw SQL, remember to update `updated_at` manually if desired.
- Foreign keys:
  - `PRAGMA foreign_keys = ON` must be enabled per connection. Scripts enable this for you.

## Troubleshooting

- FTS5 unavailable  
  Symptom: `CREATE VIRTUAL TABLE ... fts5` fails.  
  Check: `SELECT sqlite_compileoption_used('ENABLE_FTS5');`  
  Fix (macOS/Homebrew): `brew install sqlite`; then ensure your PATH uses Homebrew `sqlite3` first.

- SQLite3 Ruby gem linking issues (macOS)  
  `gem install sqlite3` sometimes links against system SQLite.  
  Try: `bundle config build.sqlite3 --with-sqlite3-dir="$(brew --prefix sqlite)"` and `bundle install`.

- Uniqueness with Russian strings  
  `COLLATE NOCASE` is primarily ASCII; for full Cyrillic collation you’d need ICU collations via extension (optional/advanced).

## Example: AR FTS search scope (optional)

In a Rails-ish context:

    Term.joins("JOIN terms_fts f ON f.rowid = terms.id")
        .where("terms.deleted_on IS NULL AND f MATCH ?", "json OR yaml")
        .order(Arel.sql("bm25(f)"))
        .limit(20)

## License

Choose your preferred license (e.g., MIT). Add a LICENSE file if you plan to share/distribute.
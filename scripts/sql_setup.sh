#!/bin/sh
################################################################################
#   File:     scripts/sql_setup.sh
#   Purpose:  Initialize SQLite DB using raw SQL files from ./sql + seed cats
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-24
################################################################################

set -eu

usage() {
  cat <<'USAGE'
Usage:
  scripts/sql_setup.sh [--db PATH] [--rebuild] [--no-seed] [--help]

Options:
  --db PATH     Path to SQLite DB file (default: ./glossary.sqlite3)
  --rebuild     Delete existing DB file before initializing
  --no-seed     Skip SQL seed (categories)
  -h, --help    Show this help

Notes:
  - Expects SQL files in ./sql:
      create_categories.sql
      create_terms.sql
      create_commands.sql
      create_examples.sql
      create_terms_fts.sql
USAGE
}

# Determine project root (parent of this script's directory)
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd)
ROOT=$(cd "$SCRIPT_DIR/.." || exit 1; pwd)

DB_PATH="${ROOT}/glossary.sqlite3"
SQL_DIR="${ROOT}/sql"
REBUILD="0"
NO_SEED="0"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --db)
      [ "$#" -ge 2 ] || { echo "Missing value for --db" >&2; exit 1; }
      DB_PATH="$2"; shift 2
      ;;
    --rebuild|--fresh)
      REBUILD="1"; shift
      ;;
    --no-seed)
      NO_SEED="1"; shift
      ;;
    -h|--help)
      usage; exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "Error: sqlite3 CLI not found. Install SQLite 3 and retry." >&2
  exit 1
fi

if [ ! -d "${SQL_DIR}" ]; then
  echo "Error: SQL directory not found: ${SQL_DIR}" >&2
  exit 1
fi

SQL_FILES="create_categories.sql create_terms.sql create_commands.sql create_examples.sql create_terms_fts.sql"
SEED_SQL="db/seeds/20251023000000_categories.sql"

# Verify required files exist
for f in $SQL_FILES; do
  if [ ! -f "${SQL_DIR}/${f}" ]; then
    echo "Missing SQL file: sql/${f}" >&2
    exit 1
  fi
done
if [ "$NO_SEED" = "0" ]; then
  if [ ! -f "${ROOT}/${SEED_SQL}" ]; then
    echo "Missing seed SQL: ${SEED_SQL}" >&2
    exit 1
  fi
fi

# Rebuild if requested
if [ "$REBUILD" = "1" ] && [ -f "${DB_PATH}" ]; then
  echo "Removing existing DB at ${DB_PATH}"
  rm -f -- "${DB_PATH}"
fi

echo "Initializing DB at ${DB_PATH}"
for f in $SQL_FILES; do
  echo "Applying sql/${f}"
  if ! sqlite3 "${DB_PATH}" < "${SQL_DIR}/${f}"; then
    echo "Apply failed for ${f}" >&2
    exit 1
  fi
done

# Check FTS5 availability
fts=$(sqlite3 "${DB_PATH}" "SELECT sqlite_compileoption_used('ENABLE_FTS5');" 2>/dev/null || printf '0')
if [ "${fts}" != "1" ]; then
  echo "Warning: FTS5 may not be enabled in your sqlite build. terms_fts might fail." >&2
fi

# Seed categories (SQL)
if [ "$NO_SEED" = "0" ]; then
  echo "Seeding categories (SQL)"
  if ! sqlite3 "${DB_PATH}" < "${ROOT}/${SEED_SQL}"; then
    echo "Seeding failed" >&2
    exit 1
  fi
fi

echo "Done."
echo "Tip: To inspect DB: sqlite3 ${DB_PATH}"

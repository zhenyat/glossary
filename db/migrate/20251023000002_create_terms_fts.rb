################################################################################
#   File:     db/migrate/20251023000002_create_terms_fts.rb
#   Purpose:  Migration file for FTS5 index and triggers on terms
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

class CreateTermsFts < ActiveRecord::Migration[8.0]
  def up
    execute "PRAGMA foreign_keys = ON;"

    execute <<~SQL
      CREATE VIRTUAL TABLE IF NOT EXISTS terms_fts USING fts5(
        en, ru, abbr_en, abbr_ru, descr_en, descr_ru,
        content='terms',
        content_rowid='id',
        tokenize='unicode61'
      );
    SQL

    execute <<~SQL
      CREATE TRIGGER IF NOT EXISTS trg_terms_ai_fts AFTER INSERT ON terms BEGIN
        INSERT INTO terms_fts(rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
        SELECT new.id, new.en, new.ru, new.abbr_en, new.abbr_ru, new.descr_en, new.descr_ru
        WHERE new.deleted_on IS NULL;
      END;
    SQL

    execute <<~SQL
      CREATE TRIGGER IF NOT EXISTS trg_terms_ad_fts AFTER DELETE ON terms BEGIN
        INSERT INTO terms_fts(terms_fts, rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
        SELECT 'delete', old.id, old.en, old.ru, old.abbr_en, old.abbr_ru, old.descr_en, old.descr_ru
        WHERE old.deleted_on IS NULL;
      END;
    SQL

    execute <<~SQL
      CREATE TRIGGER IF NOT EXISTS trg_terms_au_fts AFTER UPDATE ON terms BEGIN
        INSERT INTO terms_fts(terms_fts, rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
        SELECT 'delete', old.id, old.en, old.ru, old.abbr_en, old.abbr_ru, old.descr_en, old.descr_ru
        WHERE old.deleted_on IS NULL;

        INSERT INTO terms_fts(rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
        SELECT new.id, new.en, new.ru, new.abbr_en, new.abbr_ru, new.descr_en, new.descr_ru
        WHERE new.deleted_on IS NULL;
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS trg_terms_ai_fts;"
    execute "DROP TRIGGER IF EXISTS trg_terms_ad_fts;"
    execute "DROP TRIGGER IF EXISTS trg_terms_au_fts;"
    execute "DROP TABLE IF EXISTS terms_fts;"
  end
end

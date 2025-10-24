/***************************************************
 *  File:       create_terms_fts.sql
 *  Purpose:    create 'virtual table terms_fts' with triggers
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 ****************************************************/

PRAGMA foreign_keys = ON;

-- External-content FTS index over selected text columns of terms
CREATE VIRTUAL TABLE IF NOT EXISTS terms_fts USING fts5(
    en, ru, abbr_en, abbr_ru, descr_en, descr_ru,
    content='terms',
    content_rowid='id',
    tokenize='unicode61'
);

-- Keep FTS in sync with active (non-deleted) rows only
CREATE TRIGGER IF NOT EXISTS trg_terms_ai_fts AFTER INSERT ON terms BEGIN
    INSERT INTO terms_fts(rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT new.id, new.en, new.ru, new.abbr_en, new.abbr_ru, new.descr_en, new.descr_ru
    WHERE new.deleted_on IS NULL;
END;

CREATE TRIGGER IF NOT EXISTS trg_terms_ad_fts AFTER DELETE ON terms BEGIN
    INSERT INTO terms_fts(terms_fts, rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT 'delete', old.id, old.en, old.ru, old.abbr_en, old.abbr_ru, old.descr_en, old.descr_ru
    WHERE old.deleted_on IS NULL;
END;

CREATE TRIGGER IF NOT EXISTS trg_terms_au_fts AFTER UPDATE ON terms BEGIN
    -- Remove old document if it was active
    INSERT INTO terms_fts(terms_fts, rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT 'delete', old.id, old.en, old.ru, old.abbr_en, old.abbr_ru, old.descr_en, old.descr_ru
    WHERE old.deleted_on IS NULL;

    -- Add new document if it is active
    INSERT INTO terms_fts(rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT new.id, new.en, new.ru, new.abbr_en, new.abbr_ru, new.descr_en, new.descr_ru
    WHERE new.deleted_on IS NULL;
END;

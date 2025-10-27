/*******************************************************************************
 *  File:       create_terms_fts.sql
 *  Purpose:    create 'virtual table terms_fts' with trigger
 *
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 *  Updated:    2025-10-27  Comments added due to Chrome AI
 *******************************************************************************/

PRAGMA foreign_keys = ON;

-- External-content FTS index over selected text columns of terms
CREATE VIRTUAL TABLE IF NOT EXISTS terms_fts USING fts5(
    en, ru, abbr_en, abbr_ru, descr_en, descr_ru,
    content='terms',  -- указывает, что исходные данные находятся в таблице 'terms
    content_rowid='id', -- связывает rowid виртуальной таблицы с id исходной
    tokenize='unicode61'
);

-- Триггеры, которые будут автоматически обновлять виртуальную таблицу при изменении в исходной:

-- Keep FTS in sync with active (non-deleted) rows only
CREATE TRIGGER IF NOT EXISTS trg_terms_ai_fts AFTER INSERT ON terms BEGIN -- ai - after insert
    INSERT INTO terms_fts(rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT new.id, new.en, new.ru, new.abbr_en, new.abbr_ru, new.descr_en, new.descr_ru
    WHERE new.deleted_on IS NULL;
END;

CREATE TRIGGER IF NOT EXISTS trg_terms_ad_fts AFTER DELETE ON terms BEGIN -- ad - after delete
    INSERT INTO terms_fts(terms_fts, rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT 'delete', old.id, old.en, old.ru, old.abbr_en, old.abbr_ru, old.descr_en, old.descr_ru
    WHERE old.deleted_on IS NULL;
END;

CREATE TRIGGER IF NOT EXISTS trg_terms_au_fts AFTER UPDATE ON terms BEGIN -- au - after update
    -- Remove old document if it was active
    INSERT INTO terms_fts(terms_fts, rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT 'delete', old.id, old.en, old.ru, old.abbr_en, old.abbr_ru, old.descr_en, old.descr_ru
    WHERE old.deleted_on IS NULL;

    -- Add new document if it is active
    INSERT INTO terms_fts(rowid, en, ru, abbr_en, abbr_ru, descr_en, descr_ru)
    SELECT new.id, new.en, new.ru, new.abbr_en, new.abbr_ru, new.descr_en, new.descr_ru
    WHERE new.deleted_on IS NULL;
END;

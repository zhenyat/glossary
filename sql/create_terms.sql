/***************************************************
 *  File:       create_terms.sql
 *  Purpose:    create table 'terms'
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 ****************************************************/

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS terms (
    id          INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    en          TEXT NOT NULL COLLATE NOCASE CHECK (trim(en) <> ''),
    abbr_en     TEXT,
    ru          TEXT NOT NULL CHECK (trim(ru) <> ''),
    abbr_ru     TEXT,
    descr_en    TEXT,
    descr_ru    TEXT,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on  DATETIME,
    FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_terms_category_id ON terms(category_id);
CREATE INDEX IF NOT EXISTS idx_terms_deleted_on  ON terms(deleted_on);

-- Uniqueness per category among active terms (case-insensitive English term)
CREATE UNIQUE INDEX IF NOT EXISTS uq_terms_category_en_active
    ON terms(category_id, en COLLATE NOCASE)
    WHERE deleted_on IS NULL;
    
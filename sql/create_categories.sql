/***************************************************
 *  File:       create_categories.sql
 *  Purpose:    create table categories
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 ****************************************************/

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS categories (
    id          INTEGER PRIMARY KEY,
    name_en     TEXT NOT NULL COLLATE NOCASE CHECK (trim(name_en) <> ''),
    name_ru     TEXT,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on  DATETIME
);

-- Uniqueness among active rows (case-insensitive for English)
CREATE UNIQUE INDEX IF NOT EXISTS uq_categories_name_en_active
    ON categories(name_en COLLATE NOCASE)
    WHERE deleted_on IS NULL;

CREATE INDEX IF NOT EXISTS idx_categories_deleted_on
    ON categories(deleted_on);

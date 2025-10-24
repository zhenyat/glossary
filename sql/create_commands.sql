/***************************************************
 *  File:       create_commands.sql
 *  Purpose:    create table 'commands'
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 ****************************************************/

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS commands (
    id          INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    title       TEXT NOT NULL COLLATE NOCASE CHECK (trim(title) <> ''),
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

CREATE INDEX IF NOT EXISTS idx_commands_category_id ON commands(category_id);
CREATE INDEX IF NOT EXISTS idx_commands_deleted_on  ON commands(deleted_on);

-- Uniqueness per category among active commands (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS uq_commands_category_title_active
    ON commands(category_id, title COLLATE NOCASE)
    WHERE deleted_on IS NULL;

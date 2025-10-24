/***************************************************
 *  File:       create_examples.sql
 *  Purpose:    create table 'examples'
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 ****************************************************/

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS examples (
    id          INTEGER PRIMARY KEY,
    command_id  INTEGER NOT NULL,
    title       TEXT NOT NULL COLLATE NOCASE CHECK (trim(title) <> ''),
    descr_en    TEXT,
    descr_ru    TEXT,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on  DATETIME,
    FOREIGN KEY (command_id)
        REFERENCES commands(id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_examples_command_id ON examples(command_id);
CREATE INDEX IF NOT EXISTS idx_examples_deleted_on  ON examples(deleted_on);

-- Uniqueness per command among active examples (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS uq_examples_command_title_active
    ON examples(command_id, title COLLATE NOCASE)
    WHERE deleted_on IS NULL;

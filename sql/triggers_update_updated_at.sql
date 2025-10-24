/***************************************************
 *  File:       sql/triggers_update_updated_at.sql
 *  Purpose:    Auto-maintain updated_at on row updates (SQLite triggers)
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-24
 ****************************************************/

PRAGMA foreign_keys = ON;

-- categories: fire only when non-timestamp columns change
DROP TRIGGER IF EXISTS trg_categories_set_updated_at;
CREATE TRIGGER trg_categories_set_updated_at
AFTER UPDATE OF name_en, name_ru, deleted_on ON categories
BEGIN
  UPDATE categories SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- terms
DROP TRIGGER IF EXISTS trg_terms_set_updated_at;
CREATE TRIGGER trg_terms_set_updated_at
AFTER UPDATE OF category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru, deleted_on ON terms
BEGIN
  UPDATE terms SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- commands
DROP TRIGGER IF EXISTS trg_commands_set_updated_at;
CREATE TRIGGER trg_commands_set_updated_at
AFTER UPDATE OF category_id, title, descr_en, descr_ru, deleted_on ON commands
BEGIN
  UPDATE commands SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- examples
DROP TRIGGER IF EXISTS trg_examples_set_updated_at;
CREATE TRIGGER trg_examples_set_updated_at
AFTER UPDATE OF command_id, title, descr_en, descr_ru, deleted_on ON examples
BEGIN
  UPDATE examples SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

################################################################################
#   File:     db/migrate/20251023000001_create_core_tables.rb
#   Purpose:  Migration file for core tables
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

class CreateCoreTables < ActiveRecord::Migration[8.0]
  def up
    execute "PRAGMA foreign_keys = ON;"

    execute <<~SQL
      CREATE TABLE IF NOT EXISTS categories (
        id          INTEGER PRIMARY KEY,
        name_en     TEXT NOT NULL COLLATE NOCASE CHECK (trim(name_en) <> ''),
        name_ru     TEXT,
        created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        deleted_on  DATETIME
      );
    SQL

    execute <<~SQL
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
    SQL

    execute <<~SQL
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
    SQL

    execute <<~SQL
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
    SQL

    # Indexes and partial unique constraints
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS uq_categories_name_en_active
      ON categories(name_en COLLATE NOCASE)
      WHERE deleted_on IS NULL;
    SQL
    add_index :categories, :deleted_on, name: "idx_categories_deleted_on"

    add_index :terms, :category_id, name: "idx_terms_category_id"
    add_index :terms, :deleted_on,  name: "idx_terms_deleted_on"
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS uq_terms_category_en_active
      ON terms(category_id, en COLLATE NOCASE)
      WHERE deleted_on IS NULL;
    SQL

    add_index :commands, :category_id, name: "idx_commands_category_id"
    add_index :commands, :deleted_on,  name: "idx_commands_deleted_on"
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS uq_commands_category_title_active
      ON commands(category_id, title COLLATE NOCASE)
      WHERE deleted_on IS NULL;
    SQL

    add_index :examples, :command_id, name: "idx_examples_command_id"
    add_index :examples, :deleted_on,  name: "idx_examples_deleted_on"
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS uq_examples_command_title_active
      ON examples(command_id, title COLLATE NOCASE)
      WHERE deleted_on IS NULL;
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS examples;"
    execute "DROP TABLE IF EXISTS commands;"
    execute "DROP TABLE IF EXISTS terms;"
    execute "DROP TABLE IF EXISTS categories;"
  end
end

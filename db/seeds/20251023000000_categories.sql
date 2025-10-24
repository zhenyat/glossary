/***************************************************
 *  File:       db/seeds/20251023000000_categories.sql
 *  Purpose:    Seed initial categories (EN/RU)
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-23
 ****************************************************/

PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO categories (name_en, name_ru)
VALUES
  ('common',       'Общая лексика'),
  ('it-general',   'ИТ (общее)'),
  ('programming',  'Программирование'),
  ('unix',         'Unix/Linux'),
  ('shell',        'Командная оболочка'),
  ('git',          'Git'),
  ('rdbms',        'Реляционные СУБД'),
  ('sql',          'SQL'),
  ('sqlite',       'SQLite'),
  ('mysql',        'MySQL'),
  ('postgresql',   'PostgreSQL'),
  ('python',       'Python'),
  ('ruby',         'Ruby'),
  ('rails',        'Ruby on Rails'),
  ('javascript',   'JavaScript'),
  ('data-formats', 'Форматы данных'),
  ('finance',      'Финансы');
  
################################################################################
#   File:     db/seeds/20251023000000_categories.rb
#   Purpose:  Seed initial categories (EN/RU)
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

# Ensure foreign keys are on in this session
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")

categories = [
  { name_en: 'common',       name_ru: 'Общая лексика' },
  { name_en: 'it-general',   name_ru: 'ИТ (общее)' },
  { name_en: 'programming',  name_ru: 'Программирование' },
  { name_en: 'unix',         name_ru: 'Unix/Linux' },
  { name_en: 'shell',        name_ru: 'Командная оболочка' },
  { name_en: 'git',          name_ru: 'Git' },
  { name_en: 'rdbms',        name_ru: 'Реляционные СУБД' },
  { name_en: 'sql',          name_ru: 'SQL' },
  { name_en: 'sqlite',       name_ru: 'SQLite' },
  { name_en: 'mysql',        name_ru: 'MySQL' },
  { name_en: 'postgresql',   name_ru: 'PostgreSQL' },
  { name_en: 'python',       name_ru: 'Python' },
  { name_en: 'ruby',         name_ru: 'Ruby' },
  { name_en: 'rails',        name_ru: 'Ruby on Rails' },
  { name_en: 'javascript',   name_ru: 'JavaScript' },
  { name_en: 'data-formats', name_ru: 'Форматы данных' },
  { name_en: 'finance',      name_ru: 'Финансы' }
]

categories.each do |attrs|
  Category.find_or_create_by!(name_en: attrs[:name_en]) do |c|
    c.name_ru = attrs[:name_ru]
  end
end

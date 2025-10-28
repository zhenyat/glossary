#! /usr/bin/env ruby
################################################################################
#   File:     scripts/console.rb
#   Purpose:  Interactive console (IRB) with ActiveRecord connected and helpers
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
# frozen_string_literal: true

require "logger"
require "active_record"
require "irb"
require "irb/completion"
require "pp"

# Project paths
ROOT    = File.expand_path("..", __dir__)
DB_PATH = ENV.fetch("DB_PATH", File.join(ROOT, "glossary.sqlite3"))

def connect!
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(
    adapter:  "sqlite3",
    database: DB_PATH,
    timeout:  5000
  )
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
end

def load_models!
  # Load concerns first
  Dir[File.join(ROOT, "app", "models", "concerns", "**", "*.rb")].sort.each { |f| require f }

  # Base model
  app_record = File.join(ROOT, "app", "models", "application_record.rb")
  require app_record if File.exist?(app_record)

  # Other models
  Dir[File.join(ROOT, "app", "models", "**", "*.rb")].sort.each do |f|
    next if f.include?("/concerns/")
    next if File.expand_path(f) == File.expand_path(app_record)
    require f
  end
end

# Convenience aliases
def conn
  ActiveRecord::Base.connection
end

def quote(v)
  conn.quote(v)
end

# Helpers available in IRB
def help
  puts <<~H
    Helpers:
      tables                 # list tables/views
      schema('terms')        # print CREATE DDL for a table/view
      sql('SELECT 1')        # run raw SQL, returns array of hashes
      fts('json OR yaml')    # FTS5 search across terms (rank + highlights)
      fts('join', category: 'sql', limit: 10)
      reload!                # reload models (after code changes)
      conn                   # ActiveRecord connection
  H
  nil
end

def tables
  rows = conn.exec_query("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY name")
  rows.rows.flatten
end

def schema(name)
  q = quote(name.to_s)
  rows = conn.exec_query("SELECT sql FROM sqlite_master WHERE name = #{q}")
  if rows.rows.empty?
    puts "(not found: #{name})"
  else
    rows.rows.each { |r| puts r.first }
  end
  nil
end

def sql(q)
  conn.exec_query(q).to_a
end

def fts(query, category: nil, limit: 20)
  q_str = quote(query.to_s)
  cat_sql = ""
  cat_sql = " AND lower(c.name_en) = lower(#{quote(category)})" if category
  lim = [limit.to_i, 1].max

  sql = <<~SQL
    SELECT
      c.name_en AS category,
      t.en,
      t.ru,
      bm25(terms_fts) AS rank,
      highlight(terms_fts, 0, '[', ']') AS en_hl,
      highlight(terms_fts, 1, '[', ']') AS ru_hl
    FROM terms_fts
    JOIN terms t      ON terms_fts.rowid = t.id
    JOIN categories c ON c.id = t.category_id
    WHERE t.deleted_on IS NULL
      AND terms_fts MATCH #{q_str}
      #{cat_sql}
    ORDER BY rank
    LIMIT #{lim}
  SQL

  rows = conn.exec_query(sql).to_a
  if rows.empty?
    puts "No results for: #{query}#{category ? " in category #{category}" : ""}"
  else
    rows.each_with_index do |r, i|
      puts "#{i + 1}. [#{r["category"]}] rank=#{format('%.3f', r["rank"])}"
      puts "   en: #{r["en_hl"].nil? || r["en_hl"].empty? ? r["en"] : r["en_hl"]}"
      puts "   ru: #{r["ru_hl"].nil? || r["ru_hl"].empty? ? r["ru"] : r["ru_hl"]}"
    end
  end
  rows
end

def reload!
  load_models!
  puts "Models reloaded."
  true
end

# Boot
connect!
load_models!

# Banner
fts5 = conn.select_value("SELECT sqlite_compileoption_used('ENABLE_FTS5')").to_i == 1 rescue false
puts <<~BANNER

  Connected to: #{DB_PATH}
  FTS5 enabled: #{fts5 ? "yes" : "no"}  |  Tables: #{tables.join(", ")}

  Type `help` for helper methods. Enjoy!

BANNER

IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.start(__FILE__)

#! /usr/bin/env ruby
################################################################################
#   File:     scripts/search.rb
#   Purpose:  Run FTS5 searches over terms (ActiveRecord, CLI)
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-27
################################################################################
# frozen_string_literal: true

require "optparse"
require "active_record"

ROOT    = File.expand_path("..", __dir__)
DB_PATH = ENV.fetch("DB_PATH", File.join(ROOT, "glossary.sqlite3"))

options = { limit: 20, category: nil }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb [options] QUERY"
  opts.on("-c", "--category NAME_EN", "Filter by category name_en (e.g., 'sql')") { |v| options[:category] = v }
  opts.on("-l", "--limit N", Integer, "Limit results (default: 20)") { |v| options[:limit] = v }
  opts.on("-h", "--help", "Show help") { puts opts; exit 0 }
end
parser.parse!

query = ARGV.join(" ").strip
if query.empty?
  warn "Missing QUERY.\nExample: DB_PATH=./data/glossary.sqlite3 ruby scripts/search.rb -c data-formats 'json OR yaml'"
  exit 1
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: DB_PATH, timeout: 5000)
conn = ActiveRecord::Base.connection
conn.execute("PRAGMA foreign_keys = ON;")

q = conn.quote(query)
cat_sql = ""
if options[:category]
  cat = conn.quote(options[:category])
  cat_sql = " AND lower(c.name_en) = lower(#{cat})"
end
limit = options[:limit].to_i
limit = 1 if limit <= 0

sql = <<~SQL
  SELECT
    c.name_en AS category,
    t.en,
    t.ru,
    bm25(terms_fts) AS rank,
    highlight(terms_fts, 0, '[', ']') AS en_hl,
    highlight(terms_fts, 1, '[', ']') AS ru_hl
  FROM terms_fts
  JOIN terms t ON terms_fts.rowid = t.id
  JOIN categories c ON c.id = t.category_id
  WHERE t.deleted_on IS NULL
    AND terms_fts MATCH #{q}
    #{cat_sql}
  ORDER BY rank
  LIMIT #{limit}
SQL

rows = conn.exec_query(sql).to_a

if rows.empty?
  puts "No results for: #{query}#{options[:category] ? " in category #{options[:category]}" : ""}"
  exit 0
end

rows.each_with_index do |r, i|
  puts "#{i + 1}. [#{r["category"]}] rank=#{format('%.3f', r["rank"])}"
  puts "   en: #{r["en_hl"].nil? || r["en_hl"].empty? ? r["en"] : r["en_hl"]}"
  puts "   ru: #{r["ru_hl"].nil? || r["ru_hl"].empty? ? r["ru"] : r["ru_hl"]}"
end

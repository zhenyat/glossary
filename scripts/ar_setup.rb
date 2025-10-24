################################################################################
#   File:     scripts/ar_setup.rb
#   Purpose:  ActiveRecord connect + run migrations + load Ruby seeds (Rails-less)
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-24
################################################################################
# frozen_string_literal: true

require "logger"
require "fileutils"
require "set"
require "active_record"
require "active_support"
require "active_support/concern"

ROOT = File.expand_path("..", __dir__)
DB_PATH = ENV.fetch("DB_PATH", File.join(ROOT, "glossary.sqlite3"))
MIGRATIONS_PATH = File.join(ROOT, "db", "migrate")
SEEDS_PATH = File.join(ROOT, "db", "seeds")

def usage
  puts <<~USAGE
    Usage:
      DB_PATH=./data/glossary.sqlite3 ruby scripts/ar_setup.rb [migrate] [seed] [reset] [status]

    Commands (default: migrate seed):
      migrate  Run all migrations (db/migrate/*.rb) and record versions
      seed     Load all Ruby seed files in db/seeds/*.rb
      reset    Delete DB file and run migrate + seed
      status   Show migration status (up/down)
  USAGE
end

def connect!
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(
    adapter:  "sqlite3",
    database: DB_PATH,
    timeout:  5000
  )
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
end

def ensure_schema_migrations_table!
  conn = ActiveRecord::Base.connection
  conn.execute <<~SQL
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version varchar NOT NULL PRIMARY KEY
    );
  SQL
end

def applied_versions
  ensure_schema_migrations_table!
  ActiveRecord::Base.connection.select_values("SELECT version FROM schema_migrations")
end

def record_version!(version)
  conn = ActiveRecord::Base.connection
  v = conn.quote(version.to_s)
  conn.execute("INSERT OR IGNORE INTO schema_migrations (version) VALUES (#{v});")
end

def migration_files
  Dir[File.join(MIGRATIONS_PATH, "*.rb")].sort
end

def camelize(s)
  s.split("_").map { |t| t.empty? ? t : t[0].upcase + t[1..] }.join
end

def load_migration_class(file)
  base = File.basename(file, ".rb") # e.g., 20251023000001_create_core_tables
  version, tail = base.split("_", 2)
  class_name = camelize(tail)
  require file
  klass = Object.const_get(class_name)
  [version, class_name, klass]
rescue NameError => e
  abort "Cannot find migration class #{class_name} in #{file} (#{e.message})"
end

def list_tables
  ActiveRecord::Base.connection.exec_query("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").rows.flatten
end

def migrate!
  connect!
  ensure_schema_migrations_table!
  ActiveRecord::Migration.verbose = true

  current = applied_versions.to_set
  migration_files.each do |file|
    version, _class_name, klass = load_migration_class(file)
    next if current.include?(version)

    puts "== Migrating #{version} #{klass.name} =="
    # Instantiate and run the migration instance (avoids AR internals variance)
    klass.new.migrate(:up)
    record_version!(version)
    puts "== Migrated #{version} #{klass.name} =="
    puts "Tables now: #{list_tables.join(', ')}"
  end
end

def load_models!
  # Concerns first
  Dir[File.join(ROOT, "app", "models", "concerns", "**", "*.rb")].sort.each { |f| require f }
  # Base
  app_record = File.join(ROOT, "app", "models", "application_record.rb")
  require app_record if File.exist?(app_record)
  # Others
  Dir[File.join(ROOT, "app", "models", "**", "*.rb")].sort.each do |f|
    next if f.include?("/concerns/")
    next if File.expand_path(f) == File.expand_path(app_record)
    require f
  end
end

def seed!
  connect!
  load_models!
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
  Dir[File.join(SEEDS_PATH, "*.rb")].sort.each do |seed_file|
    puts "Seeding: #{File.basename(seed_file)}"
    load seed_file
  end
end

def status!
  connect!
  ensure_schema_migrations_table!
  current = applied_versions.to_set

  puts "Status  Version           Name"
  migration_files.each do |file|
    base = File.basename(file, ".rb")
    version, tail = base.split("_", 2)
    name = camelize(tail)
    st = current.include?(version) ? "up" : "down"
    puts "#{st.ljust(7)} #{version}  #{name}"
  end
end

def reset!
  if File.exist?(DB_PATH)
    puts "Removing DB: #{DB_PATH}"
    FileUtils.rm_f(DB_PATH)
  end
  migrate!
  seed!
end

commands = ARGV
commands = %w[migrate seed] if commands.empty?

case commands
when ["--help"], ["-h"] then usage
else
  commands.each do |cmd|
    case cmd
    when "migrate" then migrate!
    when "seed"    then seed!
    when "reset"   then reset!
    when "status"  then status!
    else
      warn "Unknown command: #{cmd}"
      usage
      exit 1
    end
  end
end

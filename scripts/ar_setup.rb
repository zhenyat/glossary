################################################################################
#   File:     scripts/ar_setup.rb
#   Purpose:  ActiveRecord connect + run migrations + load Ruby seeds
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-24
################################################################################
# frozen_string_literal: true

require "logger"
require "fileutils"
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
      migrate  Run all migrations
      seed     Load all Ruby seed files in db/seeds/*.rb
      reset    Delete DB file and run migrate + seed
      status   Show applied migration versions
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

def migrate!
  ActiveRecord::Migration.verbose = true

  begin
    context = ActiveRecord::MigrationContext.new([MIGRATIONS_PATH], ActiveRecord::SchemaMigration)
    context.migrate
  rescue StandardError => e
    warn "MigrationContext failed (#{e.class}: #{e.message}). Falling back to explicit migrate..."
    Dir[File.join(MIGRATIONS_PATH, "*.rb")].sort.each { |f| require f }
    CreateCoreTables.migrate(:up) if defined?(CreateCoreTables)
    CreateTermsFts.migrate(:up)   if defined?(CreateTermsFts)
  end
end

def load_models!
  # Load concerns first so modules like SoftDeletable are defined
  concerns = Dir[File.join(ROOT, "app", "models", "concerns", "**", "*.rb")].sort
  concerns.each { |f| require f }

  # Ensure ApplicationRecord is defined before other models
  app_record = File.join(ROOT, "app", "models", "application_record.rb")
  require app_record if File.exist?(app_record)

  # Load the rest of the models (excluding concerns and application_record)
  all_models = Dir[File.join(ROOT, "app", "models", "**", "*.rb")].sort
  others = all_models.reject { |f| f.include?("/concerns/") || File.expand_path(f) == File.expand_path(app_record) }
  others.each { |f| require f }
end

def seed!
  load_models!
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
  Dir[File.join(SEEDS_PATH, "*.rb")].sort.each do |seed_file|
    puts "Seeding: #{File.basename(seed_file)}"
    load seed_file
  end
end

def status!
  versions = ActiveRecord::Base.connection.exec_query("SELECT version FROM schema_migrations ORDER BY version")
  puts "Applied migrations:"
  versions.rows.flatten.each { |v| puts "  - #{v}" }
end

def reset!
  if File.exist?(DB_PATH)
    puts "Removing DB: #{DB_PATH}"
    FileUtils.rm_f(DB_PATH)
  end
  connect!
  migrate!
  seed!
end

commands = ARGV
commands = %w[migrate seed] if commands.empty?

case commands
when ["--help"], ["-h"] then usage
else
  connect!
  commands.each do |cmd|
    case cmd
    when "migrate" then migrate!
    when "seed"    then seed!
    when "reset"   then reset! # includes migrate+seed
    when "status"  then status!
    else
      warn "Unknown command: #{cmd}"
      usage
      exit 1
    end
  end
end

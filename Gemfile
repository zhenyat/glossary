################################################################################
#   File:     Gemfile
#   Purpose:  Dependencies for Sinatra web UI (Rack 2.x + Puma)
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
source "https://rubygems.org"

ruby "3.4.7"

gem "sinatra",         "~> 3.2"
gem "sinatra-contrib", "~> 3.2"

# Sinatra 3.x requires Rack ~> 2.2
gem "rack",            "~> 2.2", ">= 2.2.4"

gem "activerecord",    "~> 8.1"
gem "sqlite3",         ">= 1.7"

# Rack server
gem "puma",            "~> 6.4"

# Optional: silence ostruct warning on Ruby 3.4 (3.5 removes it from stdlib)
# gem "ostruct"

################################################################################
#   File:     config.ru
#   Purpose:  Rack entrypoint for Sinatra app (Bundler-aware)
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
# frozen_string_literal: true

require "bundler/setup"
# Optionally auto-require default gems:
# Bundler.require(:default)

require_relative "./app/web/app"
run GlossaryApp

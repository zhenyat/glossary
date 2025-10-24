################################################################################
#   File:     app/models/example.rb
#   Purpose:  Example model
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

class Example < ApplicationRecord
  include SoftDeletable

  belongs_to :command

  validates :title, presence: true
  validates :title, uniqueness: {
    case_sensitive: false,
    scope: :command_id,
    conditions: -> { where(deleted_on: nil) }
  }
end

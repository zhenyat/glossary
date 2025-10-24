################################################################################
#   File:     app/models/command.rb
#   Purpose:  Command model
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

class Command < ApplicationRecord
  include SoftDeletable

  belongs_to :category
  has_many   :examples, dependent: :destroy

  validates :title, presence: true
  validates :title, uniqueness: {
    case_sensitive: false,
    scope: :category_id,
    conditions: -> { where(deleted_on: nil) }
  }
end

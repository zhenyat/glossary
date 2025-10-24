################################################################################
#   File:     app/models/term.rb
#   Purpose:  Term model
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

class Term < ApplicationRecord
  include SoftDeletable

  belongs_to :category

  validates :en, presence: true
  validates :ru, presence: true
  validates :en, uniqueness: {
    case_sensitive: false,
    scope: :category_id,
    conditions: -> { where(deleted_on: nil) }
  }
end

################################################################################
#   File:     app/models/category.rb
#   Purpose:  Category model
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

class Category < ApplicationRecord
  include SoftDeletable

  has_many :terms,    dependent: :restrict_with_exception
  has_many :commands, dependent: :restrict_with_exception

  validates :name_en, presence: true,
                      uniqueness: { case_sensitive: false, conditions: -> { where(deleted_on: nil) } }
end
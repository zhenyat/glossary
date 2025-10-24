################################################################################
#   File:     app/models/concerns/soft_deletable.rb
#   Purpose:  Soft delete concern using deleted_on timestamp
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-23
################################################################################

# frozen_string_literal: true

module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deleted_on: nil) }
  end

  def soft_delete!
    update!(deleted_on: Time.current)
  end

  def restore!
    update!(deleted_on: nil)
  end

  def destroyed?
    deleted_on.present?
  end

  # Make destroy a soft-delete by default
  def destroy
    soft_delete!
  end

  # Hard delete bypassing callbacks/associations; relies on DB FKs
  def hard_destroy!
    delete
  end
end

# frozen_string_literal: true
class AddInstructedToReaction < ActiveRecord::Migration
  def change
    add_column :reactions, :instructed, :boolean
  end
end

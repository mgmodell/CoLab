# frozen_string_literal: true
class AddInstructedToReaction < ActiveRecord::Migration[4.2]
  def change
    add_column :reactions, :instructed, :boolean
  end
end

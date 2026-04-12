# frozen_string_literal: true

class AddDeletedToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :assignments, :deleted, :boolean, default: false, null: false
    add_column :bingo_games, :deleted, :boolean, default: false, null: false
    add_column :experiences, :deleted, :boolean, default: false, null: false
    add_column :projects, :deleted, :boolean, default: false, null: false
  end
end

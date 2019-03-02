# frozen_string_literal: true
class RemoveGroupCountFromBingoGame < ActiveRecord::Migration[4.2]
  def change
    remove_column :bingo_games, :group_count, :integer
  end
end

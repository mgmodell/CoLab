class RemoveGroupCountFromBingoGame < ActiveRecord::Migration
  def change
    remove_column :bingo_games, :group_count, :integer
  end
end

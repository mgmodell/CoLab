class AddActiveToBingoGame < ActiveRecord::Migration
  def change
    add_column :bingo_games, :active, :boolean
  end
end

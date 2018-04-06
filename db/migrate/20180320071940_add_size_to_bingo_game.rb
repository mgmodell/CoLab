class AddSizeToBingoGame < ActiveRecord::Migration[5.1]
  def change
    add_column :bingo_games, :size, :integer, default: 5
  end
end

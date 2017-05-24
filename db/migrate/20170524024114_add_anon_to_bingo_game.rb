class AddAnonToBingoGame < ActiveRecord::Migration
  def change
    add_column :bingo_games, :anon_topic, :string
  end
end

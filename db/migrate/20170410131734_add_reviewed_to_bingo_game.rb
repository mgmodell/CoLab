class AddReviewedToBingoGame < ActiveRecord::Migration
  def change
    add_column :bingo_games, :reviewed, :boolean
  end
end

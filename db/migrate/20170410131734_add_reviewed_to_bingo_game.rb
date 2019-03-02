# frozen_string_literal: true
class AddReviewedToBingoGame < ActiveRecord::Migration[4.2]
  def change
    add_column :bingo_games, :reviewed, :boolean
  end
end

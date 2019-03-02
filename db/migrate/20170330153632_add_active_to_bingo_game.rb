# frozen_string_literal: true
class AddActiveToBingoGame < ActiveRecord::Migration[4.2]
  def change
    add_column :bingo_games, :active, :boolean
  end
end

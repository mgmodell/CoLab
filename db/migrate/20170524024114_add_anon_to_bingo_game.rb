# frozen_string_literal: true
class AddAnonToBingoGame < ActiveRecord::Migration[4.2]
  def change
    add_column :bingo_games, :anon_topic, :string
  end
end

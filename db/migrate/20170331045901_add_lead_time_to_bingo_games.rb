# frozen_string_literal: true
class AddLeadTimeToBingoGames < ActiveRecord::Migration[4.2]
  def change
    add_column :bingo_games, :lead_time, :integer
  end
end

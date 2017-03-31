# frozen_string_literal: true
class AddLeadTimeToBingoGames < ActiveRecord::Migration
  def change
    add_column :bingo_games, :lead_time, :integer
  end
end

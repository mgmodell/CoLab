# frozen_string_literal: true
class AddProjectToBingoGame < ActiveRecord::Migration[4.2]
  def change
    add_reference :bingo_games, :project, index: true, foreign_key: true
  end
end

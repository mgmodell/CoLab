# frozen_string_literal: true
class AddCourseToBingoGame < ActiveRecord::Migration[4.2]
  def change
    add_reference :bingo_games, :course, index: true, foreign_key: true
  end
end

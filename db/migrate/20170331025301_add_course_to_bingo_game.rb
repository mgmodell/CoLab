class AddCourseToBingoGame < ActiveRecord::Migration
  def change
    add_reference :bingo_games, :course, index: true, foreign_key: true
  end
end

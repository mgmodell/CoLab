class AddProjectToBingoGame < ActiveRecord::Migration
  def change
    add_reference :bingo_games, :project, index: true, foreign_key: true
  end
end

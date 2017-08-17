# frozen_string_literal: true
class AddNotifiedFlagsToBingoGame < ActiveRecord::Migration
  def change
    add_column :bingo_games, :instructor_notified, :boolean
    change_column_default :bingo_games, :instructor_notified, false
    change_column_null :bingo_games, :instructor_notified, false
    add_column :bingo_games, :students_notified, :boolean
    change_column_default :bingo_games, :students_notified, false
    change_column_null :bingo_games, :students_notified, false
  end
end

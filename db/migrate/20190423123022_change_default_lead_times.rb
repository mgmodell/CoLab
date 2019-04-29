class ChangeDefaultLeadTimes < ActiveRecord::Migration[5.2]
  def change
    change_column_default :bingo_games, :lead_time, 3
    change_column_default :experiences, :lead_time, 3
  end
end

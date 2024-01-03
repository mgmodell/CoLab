class MakeRecordedScoreNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null( :submissions, :recorded_score, true )
  end
end

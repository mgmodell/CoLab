class MakeSubmissionValuesNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :submissions, :recorded_score, true
    change_column_null :submissions, :submitted, true
    change_column_null :submissions, :withdrawn, true
    change_column_default :submissions, :recorded_score, nil
  end
end

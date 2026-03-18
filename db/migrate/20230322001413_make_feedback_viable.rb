class MakeFeedbackViable < ActiveRecord::Migration[7.0]
  def change
    # Set up the defaults
    change_column_default :submissions, :recorded_score, 0
    change_column_default :submission_feedbacks, :calculated_score, 0
    change_column_default :rubric_row_feedbacks, :score, 0

    # Set up the nullables
    change_column_null :submissions, :recorded_score, false
    change_column_null :submission_feedbacks, :calculated_score, false
    change_column_null :rubric_row_feedbacks, :score, false
  end
end

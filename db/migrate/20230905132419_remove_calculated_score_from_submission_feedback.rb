class RemoveCalculatedScoreFromSubmissionFeedback < ActiveRecord::Migration[7.0]
  def change
    remove_column :submission_feedbacks, :calculated_score, :float
  end
end

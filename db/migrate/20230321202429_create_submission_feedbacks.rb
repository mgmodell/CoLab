class CreateSubmissionFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_feedbacks do |t|
      t.references :submission, null: false, foreign_key: true
      t.float :calculated_score
      t.text :feedback

      t.timestamps
    end
  end
end

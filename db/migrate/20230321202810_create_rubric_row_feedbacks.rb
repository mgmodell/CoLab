class CreateRubricRowFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :rubric_row_feedbacks do |t|
      t.references :submission_feedback, null: false, foreign_key: true
      t.float :score
      t.text :feedback
      t.references :criterium, null: false, foreign_key: true

      t.timestamps
    end
  end
end

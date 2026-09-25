class AddMoreMissingIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :installments, [:assessment_id, :user_id, :group_id]
    add_index :candidates, [:candidate_list_id, :candidate_feedback_id]
    add_index :rosters, [:course_id, :user_id, :role]
  end
end

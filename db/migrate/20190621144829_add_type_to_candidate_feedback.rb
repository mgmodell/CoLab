class AddTypeToCandidateFeedback < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_feedbacks, :critique, :integer, null: false, default: 3
  end
end

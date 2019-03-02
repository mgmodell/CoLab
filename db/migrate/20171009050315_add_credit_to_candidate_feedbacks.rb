class AddCreditToCandidateFeedbacks < ActiveRecord::Migration[4.2]
  def change
    add_column :candidate_feedbacks, :credit, :integer
  end
end

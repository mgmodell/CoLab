class AddCreditToCandidateFeedbacks < ActiveRecord::Migration
  def change
    add_column :candidate_feedbacks, :credit, :integer
  end
end

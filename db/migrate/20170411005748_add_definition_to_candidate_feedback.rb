class AddDefinitionToCandidateFeedback < ActiveRecord::Migration
  def change
    add_column :candidate_feedbacks, :definition, :boolean
  end
end

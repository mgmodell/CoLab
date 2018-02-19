class ReallyRemoveDefinitionFromCandidateFeedback < ActiveRecord::Migration[4.2]
  def change
    remove_column :candidate_feedbacks, :definition, :string
  end
end

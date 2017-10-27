class ReallyRemoveDefinitionFromCandidateFeedback < ActiveRecord::Migration
  def change
    remove_column :candidate_feedbacks, :definition, :string
  end
end

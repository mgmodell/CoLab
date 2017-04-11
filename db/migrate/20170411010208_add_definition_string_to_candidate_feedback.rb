class AddDefinitionStringToCandidateFeedback < ActiveRecord::Migration
  def change
    add_column :candidate_feedbacks, :definition, :string
  end
end

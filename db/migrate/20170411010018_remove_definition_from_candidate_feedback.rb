# frozen_string_literal: true
class RemoveDefinitionFromCandidateFeedback < ActiveRecord::Migration[4.2]
  def change
    remove_column :candidate_feedbacks, :definition, :boolean
  end
end

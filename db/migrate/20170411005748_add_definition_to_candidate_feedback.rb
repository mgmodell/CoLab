# frozen_string_literal: true
class AddDefinitionToCandidateFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :candidate_feedbacks, :definition, :boolean
  end
end

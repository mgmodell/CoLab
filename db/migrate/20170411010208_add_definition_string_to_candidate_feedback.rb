# frozen_string_literal: true
class AddDefinitionStringToCandidateFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :candidate_feedbacks, :definition, :string
  end
end

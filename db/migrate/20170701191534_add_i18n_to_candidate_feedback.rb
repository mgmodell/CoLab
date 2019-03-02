# frozen_string_literal: true
class AddI18nToCandidateFeedback < ActiveRecord::Migration[4.2]
  def change
    rename_column :candidate_feedbacks, :name, :name_en
    add_column :candidate_feedbacks, :name_ko, :string
    add_column :candidate_feedbacks, :definition_en, :text
    add_column :candidate_feedbacks, :definition_ko, :text

    add_index :candidate_feedbacks, :name_en, unique: true
  end
end

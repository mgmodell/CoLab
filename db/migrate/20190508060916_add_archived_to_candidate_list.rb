class AddArchivedToCandidateList < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_lists, :archived, :boolean
    add_column :candidate_lists, :current_candidate_list, :integer, null: true, index: true
    add_foreign_key :candidate_lists, :candidate_lists, column: :current_candidate_list
  end
end

class AddArchivedToCandidateList < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_lists, :archived, :boolean, default: false, null: false
    add_column :candidate_lists, :contributor_count, :integer, default: 1, null: false
    add_column :candidate_lists, :current_candidate_list_id, :integer, null: true, index: true
    add_foreign_key :candidate_lists, :candidate_lists, column: :current_candidate_list_id
  end
end

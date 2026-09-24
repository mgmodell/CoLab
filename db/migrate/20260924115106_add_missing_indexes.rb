class AddMissingIndexes < ActiveRecord::Migration[8.1]
  def change
    # Guard existing single-column indexes
    add_index :candidate_lists, :current_candidate_list_id, if_not_exists: true
    add_index :experiences, :course_id, if_not_exists: true
    add_index :reactions, :experience_id, if_not_exists: true
    add_index :diagnoses, :reaction_id, if_not_exists: true

    # Guard existing composite index (idx_reactions_lookup already exists)
    add_index :reactions, [:experience_id, :user_id], if_not_exists: true

    # New Composite & Covering Indexes
    add_index :installments, [:assessment_id, :group_id, :user_id], name: "idx_installments_graphing", if_not_exists: true
    add_index :values, [:installment_id, :factor_id, :user_id], name: "idx_values_graphing", if_not_exists: true
    add_index :rosters, [:course_id, :role, :user_id], name: "idx_rosters_course_role_user", if_not_exists: true

    # Convert Candidates term & definition indexes to FULLTEXT safely
    if index_exists?(:candidates, :term, name: "index_candidates_on_term")
      remove_index :candidates, name: "index_candidates_on_term"
    end
    add_index :candidates, :term, type: :fulltext, if_not_exists: true

    if index_exists?(:candidates, :definition, name: "index_candidates_on_definition")
      remove_index :candidates, name: "index_candidates_on_definition"
    end
    add_index :candidates, :definition, type: :fulltext, if_not_exists: true
  end
end

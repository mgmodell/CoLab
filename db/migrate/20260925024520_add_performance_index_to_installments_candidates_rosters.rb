class AddPerformanceIndexToInstallmentsCandidatesRosters < ActiveRecord::Migration[8.1]
  def change
    add_index :candidates, [:candidate_list_id, :user_id]
    add_index :values, [:installment_id, :user_id, :factor_id]
    add_index :bingo_cells, [:bingo_board_id, :row, :column]
    # Candidate filtering, counts, & group aggregations
    add_index :candidates, :filtered_consistent

    # Candidate lists lookups
    add_index :candidate_lists, [:bingo_game_id, :user_id]
    add_index :candidate_lists, [:bingo_game_id, :archived]

    # Installment & value composite lookups
    add_index :installments, [:assessment_id, :user_id, :group_id], name: 'idx_installments_assessment_user_group'
    add_index :values, [:installment_id, :factor_id, :user_id]

  end
end

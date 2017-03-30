# frozen_string_literal: true
class AddBingoToCandidateList < ActiveRecord::Migration
  def change
    add_reference :candidate_lists, :bingo_game, index: true, foreign_key: true
    add_reference :candidate_lists, :project, index: true, foreign_key: true
  end
end

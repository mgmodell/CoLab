# frozen_string_literal: true
class RemoveProjectFromCandidateList < ActiveRecord::Migration[4.2]
  def change
    remove_reference :candidate_lists, :project, index: true, foreign_key: true
  end
end

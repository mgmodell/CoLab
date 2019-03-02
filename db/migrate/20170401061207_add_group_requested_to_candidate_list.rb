# frozen_string_literal: true
class AddGroupRequestedToCandidateList < ActiveRecord::Migration[4.2]
  def change
    add_column :candidate_lists, :group_requested, :boolean
  end
end

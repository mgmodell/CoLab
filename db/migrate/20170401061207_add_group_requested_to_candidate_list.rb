# frozen_string_literal: true
class AddGroupRequestedToCandidateList < ActiveRecord::Migration
  def change
    add_column :candidate_lists, :group_requested, :boolean
  end
end

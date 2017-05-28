# frozen_string_literal: true
class AddFilteredConsistentToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :filtered_consistent, :string
  end
end

# frozen_string_literal: true
class AddFilteredConsistentToCandidate < ActiveRecord::Migration[4.2]
  def change
    add_column :candidates, :filtered_consistent, :string
  end
end

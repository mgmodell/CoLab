# frozen_string_literal: true
class RemoveNameFromCandidate < ActiveRecord::Migration[4.2]
  def change
    remove_column :candidates, :name, :string
  end
end

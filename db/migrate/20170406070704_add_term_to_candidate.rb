# frozen_string_literal: true
class AddTermToCandidate < ActiveRecord::Migration[4.2]
  def change
    add_column :candidates, :term, :string
  end
end

# frozen_string_literal: true
class AddTermToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :term, :string
  end
end

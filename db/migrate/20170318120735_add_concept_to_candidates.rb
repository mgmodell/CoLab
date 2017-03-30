# frozen_string_literal: true
class AddConceptToCandidates < ActiveRecord::Migration
  def change
    add_reference :candidates, :concept, index: true, foreign_key: true
  end
end

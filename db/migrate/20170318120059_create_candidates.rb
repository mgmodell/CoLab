# frozen_string_literal: true
class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :name
      t.text :definition
      t.references :candidate_list, index: true, foreign_key: true
      t.references :candidate_feedback, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

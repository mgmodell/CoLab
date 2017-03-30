# frozen_string_literal: true
class CreateCandidateLists < ActiveRecord::Migration
  def change
    create_table :candidate_lists do |t|
      t.references :user, index: true, foreign_key: true
      t.references :group, index: true, foreign_key: true
      t.boolean :is_group

      t.timestamps null: false
    end
  end
end

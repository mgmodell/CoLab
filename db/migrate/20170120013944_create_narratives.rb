# frozen_string_literal: true
class CreateNarratives < ActiveRecord::Migration
  def change
    create_table :narratives do |t|
      t.string :member
      t.references :scenario, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

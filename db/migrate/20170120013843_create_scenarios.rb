# frozen_string_literal: true
class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.string :name
      t.references :behavior, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

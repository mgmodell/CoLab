# frozen_string_literal: true
class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

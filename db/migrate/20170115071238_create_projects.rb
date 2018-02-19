# frozen_string_literal: true
class CreateProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.references :course, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

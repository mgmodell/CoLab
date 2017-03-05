# frozen_string_literal: true
class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.references :course, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

# frozen_string_literal: true
class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :description
      t.string :name

      t.timestamps null: false
    end
  end
end

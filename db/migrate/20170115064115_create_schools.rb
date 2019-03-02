# frozen_string_literal: true
class CreateSchools < ActiveRecord::Migration[4.2]
  def change
    create_table :schools do |t|
      t.string :description
      t.string :name

      t.timestamps null: false
    end
  end
end

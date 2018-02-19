# frozen_string_literal: true
class CreateCips < ActiveRecord::Migration[4.2]
  def change
    create_table :cips do |t|
      t.integer :code
      t.string :description

      t.timestamps null: false
    end
  end
end

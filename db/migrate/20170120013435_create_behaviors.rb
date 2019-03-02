# frozen_string_literal: true
class CreateBehaviors < ActiveRecord::Migration[4.2]
  def change
    create_table :behaviors do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end

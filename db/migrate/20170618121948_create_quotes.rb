# frozen_string_literal: true
class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string :en, unique: true
      t.string :attribution

      t.timestamps null: false
    end
  end
end

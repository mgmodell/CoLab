# frozen_string_literal: true
class CreateQuotes < ActiveRecord::Migration[4.2]
  def change
    create_table :quotes do |t|
      t.string :text_en, unique: true
      t.string :attribution

      t.timestamps null: false
    end
  end
end

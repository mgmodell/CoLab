# frozen_string_literal: true
class CreateDiagnoses < ActiveRecord::Migration[4.2]
  def change
    create_table :diagnoses do |t|
      t.references :behavior, index: true, foreign_key: true
      t.references :reaction, index: true, foreign_key: true
      t.references :week, index: true, foreign_key: true
      t.text :comment

      t.timestamps null: false
    end
  end
end

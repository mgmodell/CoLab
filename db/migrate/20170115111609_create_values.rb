# frozen_string_literal: true
class CreateValues < ActiveRecord::Migration[4.2]
  def change
    create_table :values do |t|
      t.integer :value
      t.references :user, index: true, foreign_key: true
      t.references :installment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

# frozen_string_literal: true
class CreateInstallments < ActiveRecord::Migration[4.2]
  def change
    create_table :installments do |t|
      t.datetime :inst_date
      t.references :assessment, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.text :comments
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

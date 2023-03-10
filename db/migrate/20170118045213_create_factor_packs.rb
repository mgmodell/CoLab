# frozen_string_literal: true
class CreateFactorPacks < ActiveRecord::Migration[4.2]
  def change
    create_table :factor_packs do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end

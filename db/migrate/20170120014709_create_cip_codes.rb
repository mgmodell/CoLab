# frozen_string_literal: true
class CreateCipCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :cip_codes do |t|
      t.integer :gov_code, unique: true
      t.string :description

      t.timestamps null: false
    end
  end
end

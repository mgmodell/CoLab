# frozen_string_literal: true
class CreateStyles < ActiveRecord::Migration[4.2]
  def change
    create_table :styles do |t|
      t.string :name
      t.string :filename

      t.timestamps null: false
    end
  end
end

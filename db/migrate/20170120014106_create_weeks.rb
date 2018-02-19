# frozen_string_literal: true
class CreateWeeks < ActiveRecord::Migration[4.2]
  def change
    create_table :weeks do |t|
      t.references :narrative, index: true, foreign_key: true
      t.integer :week_num
      t.text :text

      t.timestamps null: false
    end
  end
end

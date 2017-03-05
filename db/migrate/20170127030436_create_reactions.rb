# frozen_string_literal: true
class CreateReactions < ActiveRecord::Migration
  def change
    create_table :reactions do |t|
      t.references :behavior, index: true, foreign_key: true
      t.references :narrative, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.text :improvements

      t.timestamps null: false
    end
  end
end

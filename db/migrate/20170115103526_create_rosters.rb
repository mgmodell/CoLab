# frozen_string_literal: true
class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.references :role, index: true, foreign_key: true
      t.references :course, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

# frozen_string_literal: true
class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.references :course, index: true, foreign_key: true
      t.string :name
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end

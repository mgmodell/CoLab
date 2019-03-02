# frozen_string_literal: true
class CreateAssessments < ActiveRecord::Migration[4.2]
  def change
    create_table :assessments do |t|
      t.datetime :end_date
      t.datetime :start_date
      t.belongs_to :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

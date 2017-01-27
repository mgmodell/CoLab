class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.references :course, index: true, foreign_key: true
      t.string :name
      t.datetime :open_date
      t.datetime :close_date

      t.timestamps null: false
    end
  end
end

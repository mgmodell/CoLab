class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.string :name, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :rubric, null: false, foreign_key: true, type: :bigint
      t.boolean :group_enabled, null: false, default: false
      t.references :course, null: false, foreign_key: true, type: :integer
      t.references :project, null: true, foreign_key: true, type: :integer
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end

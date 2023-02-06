class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.date :open
      t.date :close
      t.references :rubric, null: false, foreign_key: true, type: :bigint
      t.boolean :group_enabled
      t.references :course, null: false, foreign_key: true, type: :integer
      t.references :project, null: true, foreign_key: true, type: :integer
      t.boolean :active

      t.timestamps
    end
  end
end

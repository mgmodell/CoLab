class AddParentToRubrics < ActiveRecord::Migration[7.0]
  def change
    add_reference :rubrics, :parent, null: false, foreign_key: {to_table: :rubrics}
    add_index :rubrics, [:name, :version, :parent_id], unique: true
    add_index :criteria, [:rubric_id, :sequence], unique: true
  end
end

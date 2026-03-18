class AddParentToRubrics < ActiveRecord::Migration[7.0]
  def change
    add_index :rubrics, [:name, :version, :parent_id], unique: true
    add_index :criteria, [:rubric_id, :sequence], unique: true

    change_column_null :rubrics, :parent_id, true
  end
end

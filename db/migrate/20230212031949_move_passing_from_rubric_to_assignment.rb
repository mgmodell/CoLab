class MovePassingFromRubricToAssignment < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :passing, :integer, null: true, default: 65
    remove_column :rubrics, :passing, :integer
  end
end

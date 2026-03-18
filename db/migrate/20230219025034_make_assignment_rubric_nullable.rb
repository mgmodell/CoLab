class MakeAssignmentRubricNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :assignments, :rubric_id, true
  end
end

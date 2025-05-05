class ModifyAssignmentDateDataTypes < ActiveRecord::Migration[7.0]
  def change
    change_column :assignments, :start_date, :datetime
    change_column :assignments, :end_date, :datetime
  end
end

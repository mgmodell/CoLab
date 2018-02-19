class DropGroupProjectCount < ActiveRecord::Migration[4.2]
  def change
    drop_table :group_project_counts
  end
end

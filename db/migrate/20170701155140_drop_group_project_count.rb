class DropGroupProjectCount < ActiveRecord::Migration
  def change
    drop_table :group_project_counts
  end
end

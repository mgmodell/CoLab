class MoveRolesToRosters < ActiveRecord::Migration
  def change
    remove_foreign_key :rosters, :roles
    drop_table :roles
    rename_column :rosters, :role_id, :role
    change_column :rosters, :role, :integer, default: 4
  end
end

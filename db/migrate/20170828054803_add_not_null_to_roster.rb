class AddNotNullToRoster < ActiveRecord::Migration
  def change
    change_column_null :rosters, :role_id, false
    change_column_null :rosters, :user_id, false
  end
end

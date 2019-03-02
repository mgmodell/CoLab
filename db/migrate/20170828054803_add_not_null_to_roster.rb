class AddNotNullToRoster < ActiveRecord::Migration[4.2]
  def change
    change_column_null :rosters, :role_id, false
    change_column_null :rosters, :user_id, false
  end
end

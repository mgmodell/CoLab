class AddUniqueToRoster < ActiveRecord::Migration[8.0]
  def change
    add_index :rosters, [:user_id, :course_id], unique: true
  end
end

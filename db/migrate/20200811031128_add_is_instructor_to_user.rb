class AddIsInstructorToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :instructor, :boolean, default: false, null: false
  end
end

class AddReferencesToGroupsUsers < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :groups_users, :users
    add_foreign_key :groups_users, :groups
  end
end

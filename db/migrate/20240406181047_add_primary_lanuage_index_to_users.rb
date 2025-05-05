class AddPrimaryLanuageIndexToUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :primary_language_id
  end
end

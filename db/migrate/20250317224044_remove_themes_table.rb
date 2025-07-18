class RemoveThemesTable < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :users, :themes
    drop_table :themes
    remove_column :users, :theme_id
    add_column :users, :theme, :string, limit: 6
  end
end

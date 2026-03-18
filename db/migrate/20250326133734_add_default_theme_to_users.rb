class AddDefaultThemeToUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :theme, :string, default: '007bff', null: false
  end
end

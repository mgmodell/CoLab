class AddAnonToUser < ActiveRecord::Migration
  def change
    add_column :users, :anon_first_name, :string
    add_column :users, :anon_last_name, :string
  end
end

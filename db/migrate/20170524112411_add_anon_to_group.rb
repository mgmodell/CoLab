class AddAnonToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :anon_name, :string
  end
end

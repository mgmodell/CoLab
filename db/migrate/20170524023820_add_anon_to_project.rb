class AddAnonToProject < ActiveRecord::Migration
  def change
    add_column :projects, :anon_name, :string
  end
end

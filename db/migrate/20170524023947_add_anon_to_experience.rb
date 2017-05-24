class AddAnonToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :anon_name, :string
  end
end

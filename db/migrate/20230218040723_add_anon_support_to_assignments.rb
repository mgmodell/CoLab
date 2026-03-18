class AddAnonSupportToAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :anon_name, :string
    add_column :assignments, :anon_description, :string
    add_column :rubrics, :anon_name, :string
    add_column :rubrics, :anon_description, :string
    add_column :rubrics, :anon_version, :integer
  end
end

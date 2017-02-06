class AddActiveToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :active, :boolean
  end
end

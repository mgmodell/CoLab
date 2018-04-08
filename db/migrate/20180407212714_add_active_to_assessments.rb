class AddActiveToAssessments < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :active, :boolean, null: false, default: true
  end
end

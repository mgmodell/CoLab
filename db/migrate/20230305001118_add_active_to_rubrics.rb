class AddActiveToRubrics < ActiveRecord::Migration[7.0]
  def change
    add_column :rubrics, :active, :boolean, null: false, default: false
  end
end

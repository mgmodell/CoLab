class AddActiveToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :active, :boolean, null: false, default: true
  end
end

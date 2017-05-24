class AddResearchToUser < ActiveRecord::Migration
  def change
    add_column :users, :research, :boolean
  end
end

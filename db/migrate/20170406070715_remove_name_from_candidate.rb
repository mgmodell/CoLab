class RemoveNameFromCandidate < ActiveRecord::Migration
  def change
    remove_column :candidates, :name, :string
  end
end

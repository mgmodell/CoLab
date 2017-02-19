class AddInstructedToReaction < ActiveRecord::Migration
  def change
    add_column :reactions, :instructed, :boolean
  end
end

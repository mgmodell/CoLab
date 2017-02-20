class AddOtherNameToReaction < ActiveRecord::Migration
  def change
    add_column :reactions, :other_name, :string
  end
end

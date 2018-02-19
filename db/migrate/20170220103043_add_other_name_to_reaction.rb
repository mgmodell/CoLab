# frozen_string_literal: true
class AddOtherNameToReaction < ActiveRecord::Migration[4.2]
  def change
    add_column :reactions, :other_name, :string
  end
end

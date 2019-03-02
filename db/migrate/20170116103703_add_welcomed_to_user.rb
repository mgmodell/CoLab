# frozen_string_literal: true
class AddWelcomedToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :welcomed, :boolean
  end
end

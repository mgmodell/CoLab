# frozen_string_literal: true
class AddWelcomedToUser < ActiveRecord::Migration
  def change
    add_column :users, :welcomed, :boolean
  end
end

# frozen_string_literal: true
class AddAdminToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean
  end
end

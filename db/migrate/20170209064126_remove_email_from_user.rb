# frozen_string_literal: true
class RemoveEmailFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :email, :string
  end
end

# frozen_string_literal: true
class AddAnonToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :anon_first_name, :string
    add_column :users, :anon_last_name, :string
  end
end

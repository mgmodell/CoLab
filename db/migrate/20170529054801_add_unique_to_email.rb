# frozen_string_literal: true
class AddUniqueToEmail < ActiveRecord::Migration[4.2]
  def change
    add_index :emails, :email, unique: true
  end
end

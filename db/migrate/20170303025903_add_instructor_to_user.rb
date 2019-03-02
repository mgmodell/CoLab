# frozen_string_literal: true
class AddInstructorToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :instructor, :boolean
  end
end

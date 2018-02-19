# frozen_string_literal: true
class RemoveInstructorFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :instructor, :boolean
  end
end

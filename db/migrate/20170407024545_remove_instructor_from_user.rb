# frozen_string_literal: true
class RemoveInstructorFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :instructor, :boolean
  end
end

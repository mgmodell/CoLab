# frozen_string_literal: true
class AddInstructorUpdatedToExperience < ActiveRecord::Migration[4.2]
  def change
    add_column :experiences, :instructor_updated, :boolean
  end
end

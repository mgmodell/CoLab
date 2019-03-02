# frozen_string_literal: true
class AddInstructorUpdatedToAssessment < ActiveRecord::Migration[4.2]
  def change
    add_column :assessments, :instructor_updated, :boolean
  end
end

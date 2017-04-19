class RemoveInstructorUpdatedFromAssessment < ActiveRecord::Migration
  def change
    remove_column :assessments, :instructor_updated, :boolean
  end
end

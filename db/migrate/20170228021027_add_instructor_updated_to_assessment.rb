class AddInstructorUpdatedToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :instructor_updated, :boolean
  end
end

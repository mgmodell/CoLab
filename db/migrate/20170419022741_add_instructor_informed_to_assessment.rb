class AddInstructorInformedToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :instructor_updated, :boolean, :null => false, :default => false
  end
end

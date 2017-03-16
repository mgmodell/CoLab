class AddInstructorUpdatedToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :instructor_updated, :boolean
  end
end

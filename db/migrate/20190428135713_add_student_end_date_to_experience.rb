class AddStudentEndDateToExperience < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :student_end_date, :datetime
  end
end

class CreateCourseOfStudies < ActiveRecord::Migration
  def change
    create_table :course_of_studies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

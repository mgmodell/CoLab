class AddCoursesCountToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :courses_count, :integer,
              default: 0, null: false
  end
end

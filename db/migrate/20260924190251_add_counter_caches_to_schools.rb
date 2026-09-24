class AddCounterCachesToSchools < ActiveRecord::Migration[8.1]
  def change
    add_column :schools, :rubrics_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        School.reset_column_information
        School.find_each do |school|
          School.reset_counters(school.id, :courses, :rubrics)
        end
      end
    end
  end
end

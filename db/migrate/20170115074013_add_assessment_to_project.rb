class AddAssessmentToProject < ActiveRecord::Migration
  def change
    add_column :projects, :start_dow, :integer
    add_column :projects, :end_dow, :integer
    add_column :projects, :active, :boolean
    add_column :projects, :start_date, :date
    add_column :projects, :end_date, :date
  end
end

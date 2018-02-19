# frozen_string_literal: true
class AddAssessmentToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :start_dow, :integer
    add_column :projects, :end_dow, :integer
    add_column :projects, :active, :boolean
    add_column :projects, :start_date, :datetime
    add_column :projects, :end_date, :datetime
  end
end

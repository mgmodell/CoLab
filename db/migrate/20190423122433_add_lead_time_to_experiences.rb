class AddLeadTimeToExperiences < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :lead_time, :integer, default: 0, null: false
  end
end

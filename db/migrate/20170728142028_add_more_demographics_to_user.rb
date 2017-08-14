class AddMoreDemographicsToUser < ActiveRecord::Migration
  def change
    add_column :users, :date_of_birth, :date
    add_reference :users, :home_state, index: true, foreign_key: true
    add_reference :users, :cip_code, index: true, foreign_key: true
    add_column :users, :primary_language_id, :integer
    add_column :users, :started_school, :date
    remove_reference :users, :age_range, index: true, foreign_key: true
  end
end

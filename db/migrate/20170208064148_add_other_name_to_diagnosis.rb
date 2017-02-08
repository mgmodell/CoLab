class AddOtherNameToDiagnosis < ActiveRecord::Migration
  def change
    add_column :diagnoses, :other_name, :string
  end
end

# frozen_string_literal: true
class AddOtherNameToDiagnosis < ActiveRecord::Migration[4.2]
  def change
    add_column :diagnoses, :other_name, :string
  end
end

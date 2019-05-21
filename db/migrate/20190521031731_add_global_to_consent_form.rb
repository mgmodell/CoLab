class AddGlobalToConsentForm < ActiveRecord::Migration[5.2]
  def change
    add_column :consent_forms, :courses_count,
               :integer, default: 0, null: false
  end
end

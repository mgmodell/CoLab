class AddFormTextToConsentForm < ActiveRecord::Migration
  def change
    add_column :consent_forms, :form_text, :text
  end
end

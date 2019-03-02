class AddActiveAndI18NToConsentForm < ActiveRecord::Migration[4.2]
  def change
    add_column :consent_forms, :start_date, :date
    add_column :consent_forms, :end_date, :date, null: true
    add_column :consent_forms, :active, :boolean, null: false, default: false

    rename_column :consent_forms, :form_text, :form_text_en
    add_column :consent_forms, :form_text_ko, :text
  end
end

class AddCourseToConsentForm < ActiveRecord::Migration[5.2]
  def change
    add_column  :courses, :consent_form_id, :integer, null: true
    add_foreign_key :courses, :consent_forms, column: :consent_form_id

    remove_reference :projects, :consent_form
  end
end

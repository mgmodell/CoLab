# frozen_string_literal: true
class AddFormTextToConsentForm < ActiveRecord::Migration[4.2]
  def change
    add_column :consent_forms, :form_text, :text
  end
end

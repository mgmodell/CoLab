# frozen_string_literal: true
class CreateConsentForms < ActiveRecord::Migration[4.2]
  def change
    create_table :consent_forms do |t|
      t.string :name
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

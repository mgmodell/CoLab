# frozen_string_literal: true
class CreateConsentLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :consent_logs do |t|
      t.boolean :accepted
      t.references :consent_form, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

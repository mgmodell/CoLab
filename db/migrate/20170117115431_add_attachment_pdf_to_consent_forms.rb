# frozen_string_literal: true
class AddAttachmentPdfToConsentForms < ActiveRecord::Migration
  def self.up
    change_table :consent_forms do |t|
      t.attachment :pdf
    end
  end

  def self.down
    remove_attachment :consent_forms, :pdf
  end
end

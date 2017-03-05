# frozen_string_literal: true
class AddConsentFormToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :consent_form, index: true, foreign_key: true
  end
end

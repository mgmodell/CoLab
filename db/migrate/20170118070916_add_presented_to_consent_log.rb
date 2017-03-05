# frozen_string_literal: true
class AddPresentedToConsentLog < ActiveRecord::Migration
  def change
    add_column :consent_logs, :presented, :boolean
  end
end

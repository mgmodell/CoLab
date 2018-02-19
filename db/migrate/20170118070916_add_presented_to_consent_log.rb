# frozen_string_literal: true
class AddPresentedToConsentLog < ActiveRecord::Migration[4.2]
  def change
    add_column :consent_logs, :presented, :boolean
  end
end

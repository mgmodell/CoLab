# frozen_string_literal: true

class ConsentLog < ApplicationRecord
  belongs_to :consent_form, inverse_of: :consent_logs
  delegate :name, :active, :start_date, :end_date,
           to: :consent_form, prefix: true

  belongs_to :user, inverse_of: :consent_logs
  has_many :projects, through: :consent_form, dependent: :nullify
end

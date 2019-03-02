# frozen_string_literal: true

class ConsentLog < ApplicationRecord
  belongs_to :consent_form, inverse_of: :consent_logs
  belongs_to :user, inverse_of: :consent_logs
  has_many :projects, through: :consent_form
end

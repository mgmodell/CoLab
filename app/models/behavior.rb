# frozen_string_literal: true

class Behavior < ApplicationRecord
  translates :name, :description
  has_many :scenarios, inverse_of: :behavior, dependent: :restrict_with_error
  has_many :reactions, inverse_of: :behavior, dependent: :nullify
  has_many :diagnoses, inverse_of: :behavior, dependent: :nullify
end

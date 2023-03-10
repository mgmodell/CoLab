# frozen_string_literal: true

class Behavior < ApplicationRecord
  translates :name, :description
  has_many :scenarios, inverse_of: :behavior
  has_many :reactions, inverse_of: :behavior
  has_many :diagnoses, inverse_of: :behavior
end

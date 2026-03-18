# frozen_string_literal: true

class Scenario < ApplicationRecord
  translates :name
  belongs_to :behavior, inverse_of: :scenarios
  has_many :narratives, inverse_of: :scenario, dependent: :destroy
end

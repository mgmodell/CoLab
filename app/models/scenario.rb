# frozen_string_literal: true
class Scenario < ActiveRecord::Base
  translates :name
  belongs_to :behavior, inverse_of: :scenarios
  has_many :narratives, inverse_of: :scenario
end

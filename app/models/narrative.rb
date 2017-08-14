# frozen_string_literal: true
class Narrative < ActiveRecord::Base
  translates :member
  belongs_to :scenario, inverse_of: :narratives
  has_many :weeks, inverse_of: :narrative
  has_one :behavior, through: :scenario

  has_many :reactions, inverse_of: :narrative
end

class Scenario < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :scenarios
  has_many :narratives, inverse_of: :scenario
end

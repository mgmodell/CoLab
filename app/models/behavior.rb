class Behavior < ActiveRecord::Base
  has_many :scenarios, inverse_of: :behavior
  has_many :reactions, inverse_of: :behavior
  has_many :diagnoses, inverse_of: :behavior
end

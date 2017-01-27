class Week < ActiveRecord::Base
  belongs_to :narrative, inverse_of: :weeks
  has_one :behavior, through: :narrative

  has_many :diagnoses, inverse_of: :week
end

class Concept < ActiveRecord::Base
  has_many :candidates, inverse_of: :concept
end

class Behavior < ActiveRecord::Base
  has_many :scenarios, inverse_of: :behavior
end

class AgeRange < ActiveRecord::Base
  has_many :users, :inverse_of => :age_range
end

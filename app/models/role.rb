class Role < ActiveRecord::Base
  has_many :users, inverse_of: :role
  has_many :rosters, inverse_of: :role
end

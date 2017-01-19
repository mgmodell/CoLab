class Gender < ActiveRecord::Base
  has_many :users, :inverse_of => :gender
end

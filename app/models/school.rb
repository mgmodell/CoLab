class School < ActiveRecord::Base
  has_many :courses, inverse_of: :school, :dependent => :destroy
end

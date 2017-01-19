class Course < ActiveRecord::Base
  belongs_to :school, :inverse_of => :courses
  has_many :projects, :inverse_of => :course

end

class Project < ActiveRecord::Base
  belongs_to :course
  has_many :groups
  has_many :assessments
end

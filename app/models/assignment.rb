class Assignment < ApplicationRecord
  belongs_to :rubric
  belongs_to :course
  belongs_to :project
end

class Experience < ActiveRecord::Base
  belongs_to :course, inverse_of: :experiences
end

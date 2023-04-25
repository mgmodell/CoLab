class RubricRowFeedback < ApplicationRecord
  belongs_to :submission_feedback, inverse_of: :rubric_row_feedbacks
  has_one :submission, through: :submission_feedback
  belongs_to :criterium
end

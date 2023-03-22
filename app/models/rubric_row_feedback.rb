class RubricRowFeedback < ApplicationRecord
  belongs_to :submissionFeedback, inverse_of: :rubric_row_feedbacks
  belongs_to :submission, through: :submission_feedbacks
  belongs_to :criterium
end

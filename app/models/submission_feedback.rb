class SubmissionFeedback < ApplicationRecord
  belongs_to :submission, inverse_of: :submission_feedbacks
  has_many :rubric_row_feedbacks, inverse_of: :submission_feedbacks
  accepts_nested_attributes_for :rubric_row_feedbacks, allow_destroy: true

end

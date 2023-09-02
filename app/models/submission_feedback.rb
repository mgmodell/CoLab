# frozen_string_literal: true

class SubmissionFeedback < ApplicationRecord
  belongs_to :submission, inverse_of: :submission_feedback
  has_many :rubric_row_feedbacks, inverse_of: :submission_feedback,
                                  dependent: :destroy, autosave: true
  accepts_nested_attributes_for :rubric_row_feedbacks, allow_destroy: true
end

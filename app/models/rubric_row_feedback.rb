# frozen_string_literal: true

class RubricRowFeedback < ApplicationRecord
  belongs_to :submission_feedback, inverse_of: :rubric_row_feedbacks
  has_one :submission, through: :submission_feedback
  belongs_to :criterium

  validate :sufficent_feedback

  private

  def sufficent_feedback
    return unless score < 100 && feedback.length < 9
    errors.add( :feedback, I18n.t( '.rubric_row_feedbacks.feedback_required'))
  end
end

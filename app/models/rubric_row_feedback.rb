# frozen_string_literal: true

class RubricRowFeedback < ApplicationRecord
  belongs_to :submission_feedback, inverse_of: :rubric_row_feedbacks
  has_one :submission, through: :submission_feedback
  belongs_to :criterium

  private

  def sufficent_feedback
    if score < 100 && feedback.length < 7
      errors.add( :feedback, I18n.t( 'feedback_required'))
    end
  end
end

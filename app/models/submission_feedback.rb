# frozen_string_literal: true

class SubmissionFeedback < ApplicationRecord
  belongs_to :submission, inverse_of: :submission_feedback
  has_many :rubric_row_feedbacks, inverse_of: :submission_feedback,
                                  dependent: :destroy, autosave: true
  accepts_nested_attributes_for :rubric_row_feedbacks, allow_destroy: true

  validate :sufficent_feedback

  private

  def sufficent_feedback
    return unless feedback.length < 1

    errors.add( :feedback, I18n.t( 'critiques.error.feedback_required' ) )
  end
end

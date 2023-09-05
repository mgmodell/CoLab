# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :assignment, inverse_of: :submissions
  belongs_to :user, inverse_of: :submissions
  belongs_to :group, inverse_of: :submissions, optional: true
  belongs_to :rubric, inverse_of: :submissions
  has_many_attached :sub_files

  has_one :submission_feedback, inverse_of: :submission, dependent: :destroy
  has_many :rubric_row_feedbacks, through: :submission_feedbacks
  has_one :course, through: :assignment

  before_validation :set_rubric
  validate :group_valid, :can_submit

  delegate :end_date, to: :assignment

  private

  def group_valid
    return unless assignment.group_enabled && group.empty?

    errors.add(:group, I18n.t('submissions.group_required'))
  end

  def set_rubric
    return unless rubric.nil? || submitted_was.nil?

    self.rubric = assignment.rubric
  end

  def get_calculated_score
    total = 0
    sum_weights = 0
    rubric_row_feedbacks.each do |rubric_row_feedback|
      sum_weights += rubric_row_feedback.criteria.weight
      total += rubric_row_feedback.criteria.weight * score
    end

    total / sum_weights
  end

  def can_submit
    if submitted.nil? && withdrawn.nil? &&
       submitted_was.nil? && withdrawn_was.nil?

      nil

    elsif submitted_was.nil? && !submitted.nil?
      self.withdrawn = nil
      self.submitted = DateTime.now
      found = false
      found ||= (assignment.text_sub && sub_text.present?)
      found ||= (assignment.link_sub && sub_link.present?)
      found ||= (assignment.file_sub && sub_files.size.positive?)
      errors.add :main, I18n.t('submissions.error.nothing_submitted') unless found

    elsif withdrawn_was.nil? && !withdrawn.nil?
      if submitted.nil?
        errors.add :withdrawn, I18n.t('submissions.error.withdraw_requires_submit')
      elsif changes.size > 1
        errors.add :withdrawn, I18n.t('submissions.error.no_changes_on_withdrawal')
      end
    elsif !submitted_was.nil?
      if recorded_score_changed? && changes.size > 1
        errors.add :recorded_score, I18n.t('submissions.error.only_score_change_post_submission')
      elsif (changes.size.positive? && !recorded_score_changed? ) || ( recorded_score_changed? && 1 < changes.size )
        errors.add :recorded_score, I18n.t('submissions.error.no_changes_once_submitted')
      end
    end
  end
end

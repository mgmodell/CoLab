class Submission < ApplicationRecord
  belongs_to :assignment, inverse_of: :submissions
  belongs_to :user, inverse_of: :submissions
  belongs_to :group, inverse_of: :submissions, optional: true
  belongs_to :rubric, inverse_of: :submissions
  has_many_attached :sub_files

  has_many :submission_feedbacks, inverse_of: :submission, dependent: :destroy
  has_many :rubric_row_feedbacks, through: :submission_feedbacks
  has_one :course, through: :assignment

  before_validation :set_rubric
  validate :group_valid, :can_submit

  def end_date
    assignment.end_date
  end

  private

  def group_valid
    return unless assignment.group_enabled && group.empty?

    errors.add(:group, I18n.t('submissions.group_required'))
  end

  def set_rubric
    if self.rubric.nil? || self.submitted_was.nil?
      self.rubric = self.assignment.rubric
    end

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
      found ||= (assignment.file_sub && sub_files.size > 0)
      errors.add :main, I18n.t('submissions.error.nothing_submitted') unless found

    elsif withdrawn_was.nil? && !withdrawn.nil?
      if submitted.nil?
        errors.add :main, I18n.t('submissions.error.withdraw_requires_submit')
      elsif changes.size > 1
        errors.add :main, I18n.t('submissions.error.no_changes_on_withdrawal')
      end
      self.withdrawn = current
    elsif !submitted_was.nil?
      if recorded_score.changed? && changes.size > 1
        errors.add :main, I18n.t('submissions.error.only_score_change_post_submission')
      else
        errors.add :main, I18n.t('submissions.error.no_changes_once_submitted')
      end
    end
  end

end

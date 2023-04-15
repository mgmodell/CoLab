class Submission < ApplicationRecord
  belongs_to :assignment, inverse_of: :submissions
  belongs_to :user, inverse_of: :submissions
  belongs_to :group, inverse_of: :submissions, optional: true
  has_many_attached :sub_files

  has_many :submission_feedbacks, inverse_of: :submission
  has_many :rubric_row_feedbacks, through: :submission_feedbacks

  validate :group_valid, :can_submit

  private

  def group_valid
    return unless assignment.group_option && group.empty?

    errors.add(:group, I18n.t('submissions.group_required'))
  end

  def can_submit
    if submitted.nil? && withdrawn.nil? &&
       submitted_was.nil? && withdrawn_was.nil?

      nil

    elsif submitted_was.nil? && !submitted.nil?
      self.withdrawn = nil
      self.submitted = current
      found = false
      found ||= (assignment.text_sub && sub_text.present?)
      found ||= (assignment.link_sub && sub_link.present?)
      found ||= (assignment.file_sub && sub_files.size > 0)
      errors.add :main, I18n.t('submissions.nothing_submitted')
    elsif withdrawn_was.nil? && !withdrawn.nil?
      if submitted.nil?
        errors.add :main, I18n.t('submissions.errors.withdraw_requires_submit')
      elsif changes.size > 1
        errors.add :main, I18n.t('submissions.errors.no_changes_on_withdrawal')
      end
      self.withdrawn = current
    elsif !submitted_was.nil?
      errors.add :main, I18n.t('submissions.errors.no_changes_once_submitted')
    end
  end
end

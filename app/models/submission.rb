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
    if self.assignment.group_option && group.empty?
      errors.add( :group, I18n.t( 'submissions.group_required'))
    end
  end

  def can_submit
    if self.submitted.nil? && self.withdrawn.nil?
      && self.submitted_was.nil? && self.withdrawn_was.nil?

      return

    elsif self.submitted_was == nil && self.submitted != nil
      self.withdrawn = nil
      self.submitted = current
      found = false
      found ||= (self.assignment.text_sub && !self.sub_text.blank?)
      found ||= (self.assignment.link_sub && !self.sub_link.blank?)
      found ||= (self.assignment.file_sub && self.sub_files.size > 0)
      errors.add :main, I18n.t( 'submissions.nothing_submitted')
    elsif self.withdrawn_was == nil && self.withdrawn != nil
      if self.submitted.nil?
        errors.add :main, I18n.t( 'submissions.errors.withdraw_requires_submit')
      elsif self.changes.size > 1
        errors.add :main, I18n.t( 'submissions.errors.no_changes_on_withdrawal')
      end
      self.withdrawn = current
    elsif !self.submitted_was.nil?
      errors.add :main, I18n.t( 'submissions.errors.no_changes_once_submitted')
    end

  end
end

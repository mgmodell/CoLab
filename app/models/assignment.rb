# frozen_string_literal: true

class Assignment < ApplicationRecord
  include TimezonesSupportConcern
  include DateSanitySupportConcern

  belongs_to :rubric, inverse_of: :assignments, optional: true
  belongs_to :course, inverse_of: :assignments
  belongs_to :project, optional: true

  has_many :submissions, inverse_of: :assignment, autosave: true, dependent: :destroy

  validates :name, :end_date, :start_date, presence: true
  before_create :anonymize

  # before_validation :init_dates # From DateSanitySupportConcern

  validate :submission_type

  # Validations
  validates :passing, numericality: { in: 0..100 }

  def get_description(anonymous = false)
    anonymous ? anon_description : description
  end

  def get_name(anonymous = false)
    anonymous ? anon_name : name
  end

  def get_type
    'Assignment'
  end

  def type
    'Assignment'
  end

  def get_link
    'assignment'
  end

  def task_data(current_user:)
    is_faculty = course.rosters.where(user: current_user).faculty.size.positive?

    group = project.group_for_user(current_user) if project.present? && !is_faculty
    link = is_faculty ? "assignment/critiques/#{id}" : "#{get_link}/#{id}"

    log = course.get_consent_log(user: current_user)
    consent_link = ("/research_information/#{log.consent_form_id}" if log.present?)
    status = if is_faculty
               submissions.where(withdrawn: nil, recorded_score: nil)
                          .and(Submission.where.not(submitted: nil))
             else
               status_for_user(current_user)
             end

    {
      id:,
      type: is_faculty ? :submission : :assignment,
      instructor_task: is_faculty,
      name: get_name(false),
      group_name: group.present? ? group.get_name(false) : nil,
      status:,
      course_name: course.get_name(false),
      start_date:,
      end_date:,
      next_date: start_date > Date.current ? start_date : end_date,
      link:,
      consent_link:,
      active:
    }
  end

  def get_submissions_for_user(current_user)
    if group_enabled
      submissions.where(group: project.group_for_user(current_user)).order(:submitted)
    else
      submissions.where(user: current_user).order(:submitted)
    end
  end

  def status_for_user(user)
    # TODO: check for graded
    get_submissions_for_user(user).size
  end

  private

  def submission_type
    return if text_sub || link_sub || file_sub

    errors.add(:submission_types, I18n.t('assignments.error.submission_type'))
  end

  def anonymize
    self.anon_name = "#{Faker::Company.profession} #{Faker::Company.industry}"
    self.anon_description = Faker::Lorem.sentence(
      word_count: 8,
      supplemental: true,
      random_words_to_add: 9
    ).to_s
  end

  def self.inform_instructors
    # TODO build a reminder mechanism

  end
end

# frozen_string_literal: true

class Assessment < ApplicationRecord
  belongs_to :project, inverse_of: :assessments
  validates :end_date, :start_date, presence: true
  has_many :installments, inverse_of: :assessment, dependent: :destroy
  has_many :factors, through: :project
  has_many :users, through: :project
  has_many :groups, through: :project

  after_validation :timezone_adjust

  # Helpful scope
  scope :still_open, -> { where('assessments.end_date >= ?', DateTime.current) }

  def is_completed_by_user(user)
    user.installments.where(assessment: self).count != 0
  end

  def next_deadline
    end_date
  end

  def group_for_user(user)
    groups = self.groups.joins(:users).where(users: { id: user })
    if groups.nil? || groups.count == 0
      groups = nil
    else
      logger.debug 'Too many groups for this assessment' if groups.count > 1
      groups = groups[0]
    end
    groups
  end

  # Utility method for populating Assessments when they are needed
  def self.set_up_assessments
    init_date = Date.today.beginning_of_day
    init_day = init_date.wday
    logger.debug "\n\t**Populating Assessments**"
    Project.includes(:course).where('active = true AND start_date <= ? AND end_date >= ?',
                                    init_date, init_date.end_of_day).each do |project|

      build_new_assessment project if project.is_available?
    end
  end

  # Here we'll give instructors a little status update at the close of each assessment period
  def self.inform_instructors
    count = 0
    date_now = DateTime.current

    Assessment.joins(:project)
              .includes(:installments, :project)
              .where('instructor_updated = false AND assessments.end_date < ? AND projects.active = TRUE',
                     date_now).each do |assessment|
      completion_hash = {}
      # Collect data for notification and anonymize comments
      assessment.installments.each do |inst|
        completion_hash[inst.user.email] = { name: inst.user.name(false), status: inst.inst_date.to_s }
        inst.anonymize_comments
        puts inst.errors.full_messages unless inst.errors.empty?
      end

      assessment.project.course.enrolled_students.each do |student|
        completion_hash[student.email] = { name: student.name(false), status: 'Incomplete' } unless completion_hash[student.email].present?
      end
      # Retrieve the course instructors
      # Retrieve names of those who did not complete their assessments
      # InstructorNewsLetterMailer.inform( instructor ).deliver_later
      assessment.project.course.instructors.each do |instructor|
        AdministrativeMailer.summary_report(assessment.project.get_name(false) + ' (assessment)',
                                            assessment.project.course.pretty_name(false),
                                            instructor,
                                            completion_hash).deliver_later
        count += 1
      end

      assessment.instructor_updated = true
      assessment.save
    end
    logger.debug "\n\t********#{count} Assessment Reports sent to Instructors**"
  end

  # Create an assessment for a project if warranted
  def self.build_new_assessment(project)
    tz = ActiveSupport::TimeZone.new(project.course.timezone)

    init_date = Date.today
    init_day = init_date.wday
    assessment = Assessment.new

    day_delta = init_day - project.start_dow
    if day_delta == 0
      assessment.start_date = init_date
    else
      day_delta = 7 + day_delta if day_delta < 0
      assessment.start_date = init_date - day_delta.days
    end
    assessment.start_date = assessment.start_date.beginning_of_day

    # calc period
    period = project.end_dow > project.start_dow ?
      project.end_dow - project.start_dow :
      7 - project.start_dow + project.end_dow

    assessment.end_date = assessment.start_date + period.days
    assessment.end_date = assessment.end_date.end_of_day

    existing_assessment_count = project.assessments.where(
      'start_date = ? AND end_date = ?',
      (assessment.start_date - tz.utc_offset).change(usec: 0),
      (assessment.end_date - tz.utc_offset).change(usec: 0)
    ).count

    if existing_assessment_count == 0
      assessment.project = project
      assessment.save
      puts assessment.errors.full_messages unless assessment.errors.empty?
    end
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(project.course.timezone)
    self.start_date -= course_tz.utc_offset if start_date_changed?

    self.end_date -= course_tz.utc_offset if end_date_changed?
  end
end

# frozen_string_literal: true
require 'chronic'

class Assessment < ActiveRecord::Base
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
    0 != user.installments.where(assessment: self).count
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
    # TODO: Add timezone support here
    init_date = Date.today.beginning_of_day
    init_day = init_date.wday
    logger.debug "\n\t**Populating Assessments**"
    Project.where('active = true AND start_date <= ? AND end_date >= ?',
                  init_date, init_date.end_of_day).each do |project|

      build_new_assessment project if project.is_available?
    end
  end

  # Here we'll give instructors a little status update at the close of each assessment period
  def self.inform_instructors
    Assessment.where('instructor_updated = false AND end_date < ?', DateTime.current).each do |assessment|
      completion_hash = {}
      assessment.installments.each do |inst|
        completion_hash[inst.user] = inst.inst_date.to_s
      end

      assessment.project.course.enrolled_students.each do |student|
        completion_hash[student] = 'Incomplete' unless completion_hash[student].present?
      end
      # Retrieve the course instructors
      # Retrieve names of those who did not complete their assessments
      # InstructorNewsLetterMailer.inform( instructor ).deliver_later
      assessment.project.course.instructors.each do |instructor|
        AdministrativeMailer.summary_report(assessment.project.name + ' (assessment)',
                                            instructor,
                                            completion_hash).deliver_later
      end

      assessment.instructor_updated = true
      assessment.save
    end
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
      assessment.start_date = Chronic.parse('last ' + Date::DAYNAMES[project.start_dow])
    end
    assessment.start_date = assessment.start_date.beginning_of_day

    day_delta = project.end_dow - init_day
    if day_delta == 0
      assessment.end_date = init_date.end_of_day
    else
      assessment.end_date = Chronic.parse('this ' + Date::DAYNAMES[project.end_dow])
    end
    assessment.end_date = assessment.end_date.end_of_day

    existing_assessment_count = project.assessments.where(
      'start_date = ? AND end_date = ?',
      (assessment.start_date - tz.utc_offset).change(usec: 0),
      (assessment.end_date - tz.utc_offset).change(usec: 0)
    ).count

    if existing_assessment_count == 0
      assessment.project = project
      assessment.save
    end
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(project.course.timezone)
    self.start_date -= course_tz.utc_offset if start_date_changed?

    self.end_date -= course_tz.utc_offset if end_date_changed?
  end
end

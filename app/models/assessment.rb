# frozen_string_literal: true

class Assessment < ApplicationRecord
  belongs_to :project, inverse_of: :assessments
  has_one :course, through: :project
  validates :end_date, :start_date, presence: true
  has_many :installments, inverse_of: :assessment, dependent: :destroy
  has_many :factors, through: :project
  has_many :users, through: :project
  has_many :groups, through: :project

  # Helpful scope
  scope :active_at, lambda { |date|
                      joins(:project)
                        .where('assessments.end_date >= ?', date)
                        .where('assessments.start_date <= ?', date)
                        .where(assessments: { active: true })
                        .where(projects: { active: true })
                    }

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
    init_date = DateTime.current
    logger.debug "\n\t**Populating Assessments**"
    Project.includes(:course).where('active = true AND start_date <= ? AND end_date >= ?',
                                    init_date, init_date.end_of_day).find_each do |project|
      configure_current_assessment project if project.is_available?
    end
  end

  # Here we'll give instructors a little status update at the close of each assessment period
  def self.inform_instructors
    count = 0
    date_now = DateTime.current

    Assessment.joins(:project)
              .includes(:installments)
              .where(assessments: { active: true }, instructor_updated: false, projects: { active: true })
              .where('assessments.end_date < ?', date_now)
              .find_each do |assessment|
      completion_hash = {}
      # Collect data for notification and anonymize comments
      assessment.installments.each do |inst|
        completion_hash[inst.user.email] = { name: inst.user.name(false), status: inst.inst_date.to_s }
        inst.anonymize_comments
        logger.debug inst.errors.full_messages unless inst.errors.empty?
      end

      assessment.project.course.enrolled_students.each do |student|
        if completion_hash[student.email].blank?
          completion_hash[student.email] = { name: student.name(false), status: 'Incomplete' }
        end
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
  def self.configure_current_assessment(project)
    tz = ActiveSupport::TimeZone.new(project.course.timezone)

    init_date = DateTime.current
    init_date_in_tz = tz.parse(init_date.to_s).beginning_of_day
    init_day = init_date_in_tz.wday
    assessment = Assessment.new
    assessment.active = true

    day_delta = init_day - project.start_dow
    if day_delta == 0
      assessment.start_date = init_date_in_tz.beginning_of_day
    else
      day_delta = 7 + day_delta if day_delta < 0
      assessment.start_date = (init_date_in_tz - day_delta.days)
    end
    assessment.start_date = tz.parse(assessment.start_date.to_s).beginning_of_day

    # calc period
    period = project.end_dow > project.start_dow ?
      project.end_dow - project.start_dow :
      7 - project.start_dow + project.end_dow

    assessment.end_date = assessment.start_date + period.days
    assessment.end_date = tz.parse(assessment.end_date.to_s).end_of_day.change(sec: 0)

    existing_assessments = project.assessments.where(
      'start_date <= ? AND end_date >= ?',
      init_date_in_tz,
      init_date_in_tz
    )

    if existing_assessments.empty? &&
       assessment.start_date <= init_date &&
       assessment.end_date >= init_date
      assessment.project = project
      assessment.save
      logger.debug assessment.errors.full_messages unless assessment.errors.empty?

    elsif existing_assessments.count == 1
      existing_assessment = existing_assessments[0]
      if project.is_available?
        existing_assessment.start_date = assessment.start_date
        existing_assessment.end_date = assessment.end_date
        existing_assessment.active = true

      # if the project is not available, but there's a current assessment,
      # then we should deactivate it.
      else
        existing_assessment.active = false
      end
      existing_assessment.save
    else
      msg = "\n\tToo many current assessments for this project: "
      msg += "#{existing_assessments.count} #{existing_assessments.collect(&:id)}"
      logger.debug msg
    end
  end

end

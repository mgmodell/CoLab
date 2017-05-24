# frozen_string_literal: true
require 'forgery'
class Course < ActiveRecord::Base
  belongs_to :school, inverse_of: :courses
  has_many :projects, inverse_of: :course, dependent: :destroy
  has_many :rosters, inverse_of: :course, dependent: :destroy
  has_many :bingo_games, inverse_of: :course, dependent: :destroy
  has_many :users, through: :rosters

  has_many :experiences, inverse_of: :course, dependent: :destroy

  validates :timezone, :school, :start_date, :end_date, presence: true
  validates :name, presence: true
  validate :date_sanity
  validate :activity_date_check

  before_validation :timezone_adjust
  before_create :anonymize

  def prettyName( anonymous=false )
    prettyName = ''
    unless anonymous
      if number.present?
        prettyName = "#{name} (#{number})"
      else
        prettyName = name
      end
    else
      prettyName = "#{anon_name} (#{anon_number})"
    end
    prettyName
  end

  def get_name( anonymous=false )
    anonymous ? anon_name : name
  end

  def get_number( anonymous=false )
    anonymous ? anon_number : number
  end

  def set_user_role(user, role)
    role = Role.where(name: role).take if role.class == String
    roster = rosters.where(user: user).take
    roster = Roster.new(user: user, course: self) if roster.nil?
    roster.role = role
    roster.save
  end

  def drop_student(user)
    roster = Roster.where(user: user, course: self).take
    roster.role = Role.dropped.take
    roster.save
  end

  def get_user_role(user)
    roster = rosters.where(user: user).take
    roster.nil? ? nil : roster.role
  end

  # Validation check code
  def date_sanity
    if start_date > end_date
      errors.add(:start_dow, 'The start date must come before the end date')
    end
    errors
  end

  # TODO: - check for date sanity of experiences and projects
  def activity_date_check
    experiences.each do |experience|
      if experience.start_date < start_date
        errors.add(:start_date, 'Experience "' + experience.name + '" currently starts before this course does.')
      end
      if experience.end_date > end_date
        errors.add(:start_date, 'Experience "' + experience.name + '" currently ends after this course does.')
      end
    end
    projects.each do |project|
      if project.start_date < start_date
        errors.add(:start_date, 'Project "' + project.name + '" currently starts before this course does.')
      end
      if project.end_date > end_date
        errors.add(:start_date, 'Project "' + project.name + '" currently ends after this course does.')
      end
    end
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(timezone)
    user_tz = Time.zone

    # TZ corrections
    new_date = start_date - user_tz.utc_offset + course_tz.utc_offset
    self.start_date = new_date.getlocal(course_tz.utc_offset).beginning_of_day if start_date_changed?
    new_date = end_date - user_tz.utc_offset + course_tz.utc_offset
    self.end_date = new_date.getlocal(course_tz.utc_offset).end_of_day if end_date_changed?
  end

  def add_user_by_email(user_email, instructor = false)
    role_name = instructor ? 'Instructor' : 'Invited Student'
    role = Role.where(name: role_name).take
    # Searching for the student and:
    user = User.joins(:emails).where(emails: { email: user_email }).take

    passwd = (0...8).map { (65 + rand(26)).chr }.join

    if user.nil?
      user = User.create(email: user_email, admin: false, timezone: timezone, password: passwd, school: school) if user.nil?
    end

    existing_roster = Roster.where(course: self, user: user).take
    if existing_roster.nil?
      Roster.create(user: user, course: self, role: role)
    else
      existing_roster.role = role
      existing_roster.save
    end
    # Do we want to send an invitation email?
  end

  def add_students_by_email(student_emails)
    student_emails.split(/\s*,\s*/).each do |email|
      add_user_by_email email
    end
  end

  def add_instructors_by_email(instructor_emails)
    instructor_emails.split(/\s*,\s*/).each do |email|
      add_user_by_email(email, true)
    end
  end

  def enrolled_students
    rosters.joins(:role).where('roles.name = ? OR roles.name = ?', 'Enrolled Student', 'Invited Student').collect(&:user)
  end

  def instructors
    rosters.joins(:role).where('roles.name = ?', 'Instructor').collect(&:user)
  end

  private
    def anonymize
      anon_name = "Beginning #{Forgery::Name.industry}"
      dpts = [ 'BUS', 'MED', 'ENG', 'RTG', 'MSM', 'LEH', 'EDP',
               'GEO', 'IST', 'MAT', 'YOW', 'GFB', 'RSV', 'CSV',  'MBV' ]
      anon_number = "#{dpts.sample}-#{rand(100..700)}"
    end
end

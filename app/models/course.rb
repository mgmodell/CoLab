class Course < ActiveRecord::Base
  belongs_to :school, inverse_of: :courses
  has_many :projects, inverse_of: :course
  has_many :rosters, inverse_of: :course
  has_many :users, through: :rosters

  has_many :experiences, inverse_of: :course

  validates :timezone, :start_date, :end_date, presence: true
  validate :date_sanity

  after_validation :timezone_adjust

  # Validation check code
  def date_sanity
    if start_date > end_date
      errors.add(:start_dow, 'The start date must come before the end date')
    end
    errors
  end

  def timezone_adjust
    tz = ActiveSupport::TimeZone.new(timezone)
    self.start_date -= tz.utc_offset if start_date_changed?
    self.end_date -= tz.utc_offset if end_date_changed?
  end

  def get_roster_for_user(user)
    rosters.where(user: user).take
  end

  def add_student_by_email(student_email, instructor: false)
    role_name = instructor ? "Instructor" : "Invited Student"
    role = Role.where(name: role_name ).take
    # Searching for the student and:
    user = User.joins(:emails).where(emails: { email: student_email }).take

    passwd = (0...8).map { (65 + rand(26)).chr }.join

    if user.nil?
      user = User.create(email: student_email, admin: false, timezone: 'UTC', password: passwd) if user.nil?
      user.send_reset_password_instructions
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
      add_student_by_email email
    end
  end
end

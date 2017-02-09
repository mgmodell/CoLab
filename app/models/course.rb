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

  def get_roster_for_user( user )
    rosters.where( user: user ).take
  end

  def add_student_by_email student_email
    #TODO: Finish this up by:
    #Searching for the student and:
      # creating a roster for them if they exist
      # Send them an invitation email

      # creating a user if they don't exist
      # making sure an invitation email is sent to them
      # create a roster for them

  end

  def add_students_by_email student_emails
    student_emails.split(/\s*,\s*/).each do |email|
      add_student_by_email email
    end
  end
end

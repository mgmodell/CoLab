class Assessment < ActiveRecord::Base
  belongs_to :project, inverse_of: :assessments
  validates :end_date, :start_date, presence: true
  has_many :installments, inverse_of: :assessment
  has_many :factors, through: :project

  before_save :timezone_adjust

  # Helpful scope
  scope :still_open, -> { where('assessments.end_date >= ?', DateTime.now.in_time_zone) }

  def is_completed_by_user(user)
    0 != user.installments.where(assessment: self).count
  end

  #Utility method for populating Assessments when they are needed
  def self.set_up_assessments
    init_date = DateTime.now.beginning_of_day
    init_day = init_date.wday
    logger.debug "\n\t**Populating Assessments**"
    Project.where( "active = true AND start_date <= ? AND end_date >= ?",
      init_date, init_date.end_of_day ).each do |assessment|

      if( assessment.is_available? )
        self.build_new_assessment assessment.project
      end
    end
  end

  #Send out email reminders to those who have yet to complete their waiting assessments
  def self.send_reminder_emails
    logger.debug "Sending reminder emails"
    finished_users = User.joins( :installments => :assessment ).
      where( "assessments.start_date < ? AND assessments.end_date > ?",
      Date.today, Date.today)
 
    current_users = User.joins( :groups => { :project => :assessments } ).
      where( "assessments.start_date <= ? AND assessments.end_date >= ?", Datetime.current, Datetime.current ).
      joins( "LEFT OUTER JOIN installments ON assessments.id = installments.assessment_id " +
             "AND installments.user_id = users.id" ).to_a

    finished_users.each do |user|
      current_users.delete user
    end

    #Make sure all the users are unique
    uniqued = Hash.new
    current_users.each do |u|
      uniqued[ u ] = 1
    end

    uniqued.keys.each.do |u|
      if !u.last_emailed.today?
        ReminderMailer.remind( u ).deliver
        u.last_emailed = DateTime.current
      end
    end
  end
  

  #Create an assessment for a project if warranted
  def self.build_new_assessment(project)
    init_date = Date.today.beginning_of_day
    init_day = init_date.wday
    assessment = Assessment.new

    day_delta = init_day - project.start_dow
    if day_delta == 0
      assessment.start_date = init_date
    else
      assessment.start_date = Chronic.parse('last ' + Date::DAYNAMES[project.start_dow])
    end

    day_delta = project.end_dow - init_day
    if day_delta == 0
      assessment.end_date = init_date.end_of_day
    else
      assessment.end_date = Chronic.parse('this ' + Date::DAYNAMES[project.end_dow])
    end

    existing_assessment_count = project.assessments.where(
      'start_date = ? AND end_date = ?',
      assessment.start_date.to_date, assessment.end_date.to_date
    ).count

    if existing_assessment_count == 0
      assessment.project = project
      assessment.save
    end
  end

  def self.set_up_assessments
    # TODO: Add timezone support here
    init_date = Date.today.beginning_of_day
    init_day = init_date.wday
    Project.where(
      'active = true AND start_date <= ? AND end_date >= ?',
      init_date, init_date.end_of_day
    ).each do |project|

      build_new_assessment project if project.is_available?
    end
  end

  def timezone_adjust
    if start_date.zone != project.course.timezone
      start_date = ActiveSupport::TimeZone.new(project.course.timezone).local_to_utc(start_date)
      end_date = ActiveSupport::TimeZone.new(project.course.timezone).local_to_utc(end_date)
    end
  end
end

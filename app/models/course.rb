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

  def pretty_name(anonymous = false)
    prettyName = ''
    prettyName = if anonymous
                   "#{anon_name} (#{anon_number})"
                 else
                   if number.present?
                     "#{name} (#{number})"
                   else
                     name
                                end
                 end
    prettyName
  end

  def get_activities
    activities = projects.to_a
    activities.concat bingo_games
    activities.concat experiences
    activities.sort_by(&:end_date)
  end

  def get_name(anonymous = false)
    anonymous ? anon_name : name
  end

  def get_number(anonymous = false)
    anonymous ? anon_number : number
  end

  def set_user_role(user, role)
    roster = rosters.where(user: user).take
    roster = Roster.new(user: user, course: self) if roster.nil?
    roster.role = role
    roster.save
  end

  def drop_student(user)
    roster = Roster.where(user: user, course: self).take
    roster.role = Roster.roles[:dropped_student]
    roster.save
  end

  def get_user_role(user)
    roster = rosters.where(user: user).take
    roster.role
  end

  def copy_from_template( new_start: )
    #Timezone checking here
    course_tz = ActiveSupport::TimeZone.new(self.timezone)
    new_start = course_tz.utc_to_local( new_start.getlocal )
    date_difference = new_start - self.start_date.time
    puts "\t date difference: #{date_difference} #{new_start.class} #{self.start_date.class}"
    new_course = nil

    Course.transaction do
      #create the course
      puts "new date: #{self.start_date + date_difference}"
      new_course = Course.create(
        name: "Copy of #{self.name}",
        number: "Copy of #{self.number}",
        description: self.description,
        timezone: self.timezone,
        school: self.school,
        start_date: self.start_date + date_difference,
        end_date: self.end_date + date_difference
      )
      puts "#{new_course.start_date}"

      #copy the rosters
      self.rosters.faculty.each do |roster|
        new_obj = Roster.create(
          role: roster.role,
          user: roster.user,
          course: new_course
        )
      end

      #copy the projects
      proj_hash = {}
      self.projects.each do |project|
        new_obj = Project.create(
          name: project.name,
          style: project.style,
          factor_pack: project.factor_pack,
          start_date: project.start_date + date_difference,
          end_date: project.end_date + date_difference,
          start_dow: project.start_dow,
          end_dow: project.end_dow,
          course: new_course
        )
        proj_hash[ project ] = new_obj
      end

      #copy the experiences
      self.experiences.each do |experience|
        Experience.create(
          name: experience.name,
          start_date: experience.start_date + date_difference,
          end_date: experience.end_date + date_difference,
          course: new_course
        )
      end

      #copy the bingo! games
      self.bingo_games.each do |bingo_game|
        BingoGame.create(
          topic: bingo_game.topic,
          description: bingo_game.description,
          link: bingo_game.link,
          source: bingo_game.source,
          group_option: bingo_game.group_option,
          individual_count: bingo_game.individual_count,
          lead_time: bingo_game.lead_time,
          group_discount: bingo_game.group_discount,
          project: proj_hash[ bingo_game.project ],
          start_date: bingo_game.start_date + date_difference,
          end_date: bingo_game.end_date + date_difference,
          course: new_course
        )
      end

      new_course.save
    end
    new_course
  end

  def add_user_by_email(user_email, instructor = false)
    role = instructor ? Roster.roles[:instructor] : Roster.roles[:invited_student]
    # Searching for the student and:
    user = User.joins(:emails).where(emails: { email: user_email }).take

    passwd = (0...8).map { rand(65..90).chr }.join

    if user.nil?
      user = User.create(email: user_email, admin: false, timezone: timezone, password: passwd, school: school) if user.nil?
      end

    unless user.nil?
      existing_roster = Roster.where(course: self, user: user).take
      if existing_roster.nil?
        Roster.create(user: user, course: self, role: role)
      else
        existing_roster.role = role
        existing_roster.save
      end
    # TODO: Let's add course invitation emails here in the future
  end
  end

  def add_students_by_email(student_emails)
    student_emails.split(/[\s,]+/).each do |email|
      add_user_by_email email
    end
  end

  def add_instructors_by_email(instructor_emails)
    instructor_emails.split(/[\s,]+/).each do |email|
      add_user_by_email(email, true)
    end
  end

  def enrolled_students
    rosters.includes(user: [:emails]).enrolled_student.collect(&:user)
  end

  def instructors
    rosters.instructor.collect(&:user)
  end

  private

  # Validation check code
  def date_sanity
    if start_date.blank? || end_date.blank?
      errors.add(:start_dow, 'The start date is required' ) if start_date.blank?
      errors.add(:end_dow, 'The end date is required' ) if end_date.blank?
    elsif start_date > end_date
      errors.add(:start_dow, 'The start date must come before the end date')
    end
    errors
  end

  # TODO: - check for date sanity of experiences and projects
  def activity_date_check
    puts '========= date check'
    experiences.reload.each do |experience|
      if experience.start_date < start_date
        msg = errors[ :start_date ].blank? ? '' : errors[ :start_date ]
        msg = "Experience '#{experience.name}' currently starts before this course does"
        msg += " (#{experience.start_date} < #{start_date})."
        errors.add(:start_date, msg )
      end
      if experience.end_date > end_date
        msg = errors[ :end_date ].blank? ? '' : errors[ :end_date ]
        msg = "Experience '#{experience.name}' currently ends after this course does"
        msg += " (#{experience.end_date} > #{end_date})."
        errors.add(:end_date, msg )
      end
    end
    projects.reload.each do |project|
      if project.start_date < start_date
        msg = errors[ :start_date ].blank? ? '' : errors[ :start_date ]
        msg += "Project '#{project.name}' currently starts before this course does"
        msg += " (#{project.start_date} < #{start_date})."
        errors.add(:start_date, msg )
      end
      if project.end_date > end_date
        msg = errors[ :end_date ].blank? ? '' : errors[ :end_date ]
        msg = "Project '#{project.name}' currently ends after this course does"
        msg += " (#{project.end_date} > #{end_date})."
        errors.add(:end_date, msg )
      end
    end
    bingo_games.reload.each do |bingo_game|
      if bingo_game.start_date < start_date
        msg = errors[ :start_date ].blank? ? '' : errors[ :start_date ]
        msg = "Bingo! '#{bingo_game.topic}' currently starts before this course does "
        msg += " (#{bingo_game.start_date} < #{start_date})."
        errors.add(:start_date, msg )
      end
      if bingo_game.end_date > end_date
        msg = errors[ :end_date ].blank? ? '' : errors[ :end_date ]
        msg = "Bingo! '#{bingo_game.topic}' currently ends after this course does "
        msg += " (#{bingo_game.end_date} > #{end_date})."
        errors.add(:end_date, msg )
      end
    end
  end

  def anonymize
    levels = %w[Beginning Intermediate Advanced]
    self.anon_name = "#{levels.sample} #{Forgery::Name.industry}"
    dpts = %w[BUS MED ENG RTG MSM LEH EDP
              GEO IST MAT YOW GFB RSV CSV MBV]
    self.anon_number = "#{dpts.sample}-#{rand(100..700)}"
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(timezone)
    #TODO: must handle changing timezones at some point

    # TZ corrections
    if (start_date_changed? || timezone_changed? ) && start_date.present?
      puts "tz: #{course_tz}"
      new_date = course_tz.local( start_date.year, start_date.month, start_date.day )
      puts "sd: #{new_date}"
      self.start_date = new_date
    end

    if (end_date_changed? || timezone_changed? ) && end_date.present?
      new_date = course_tz.local( end_date.year, end_date.month, end_date.day )
      self.end_date = new_date.end_of_day
    end
    puts "\tcourse start: #{start_date} end: #{end_date}"

    if timezone_changed? && timezone_was.present?
      puts 'update timezones'
      Course.transaction do
        offset_delta = course_tz.utc_offset - ActiveSupport::TimeZone.new( timezone_was ).utc_offset
        projects.reload.each do |project|
          puts "\t\twas #{project.start_date} and #{project.end_date}"
          project.start_date = project.start_date - offset_delta
          project.end_date = project.end_date - offset_delta
          project.save( validate: false )
          puts "\t\tis  #{project.start_date} and #{project.end_date}"
        end
        experiences.reload.each do |experience|
          experience.start_date = experience.start_date - offset_delta
          experience.end_date = experience.end_date - offset_delta
          experience.save( validate: false )
        end
        bingo_games.each do |bingo_game|
          bingo_game.reload.start_date = bingo_game.start_date - offset_delta
          bingo_game.end_date = bingo_game.end_date - offset_delta
          bingo_game.save( validate: false )
        end
      end
    end
  end

end

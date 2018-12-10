# frozen_string_literal: true

require 'forgery'
class Course < ApplicationRecord
  belongs_to :school, inverse_of: :courses
  has_many :projects, inverse_of: :course, dependent: :destroy
  has_many :rosters, inverse_of: :course, dependent: :destroy
  has_many :bingo_games, inverse_of: :course, dependent: :destroy
  has_many :users, through: :rosters

  has_many :experiences, inverse_of: :course, dependent: :destroy

  validates :timezone, :start_date, :end_date, presence: true
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
    logger.debug roster.errors.full_messages unless roster.errors.empty?
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

  def copy_from_template(new_start:)
    # Timezone checking here
    course_tz = ActiveSupport::TimeZone.new(timezone)
    new_start = course_tz.utc_to_local(new_start).beginning_of_day
    d = start_date
    date_difference = new_start - course_tz.local(d.year, d.month, d.day).beginning_of_day
    new_course = nil

    Course.transaction do
      # create the course

      new_course = school.courses.new(
        name: "Copy of #{name}",
        number: "Copy of #{number}",
        description: description,
        timezone: timezone,
        start_date: start_date + date_difference,
        end_date: end_date + date_difference
      )

      # copy the rosters
      rosters.faculty.each do |roster|
        new_obj = new_course.rosters.new(
          role: roster.role,
          user: roster.user
        )
        new_obj.save
      end

      # copy the projects
      proj_hash = {}
      projects.each do |project|
        new_obj = new_course.projects.new(
          name: project.name,
          style: project.style,
          factor_pack: project.factor_pack,
          start_date: project.start_date + date_difference,
          end_date: project.end_date + date_difference,
          start_dow: project.start_dow,
          end_dow: project.end_dow
        )
        new_obj.save
        proj_hash[project] = new_obj
      end

      # copy the experiences
      experiences.each do |experience|
        new_obj = new_course.experiences.new(
          name: experience.name,
          start_date: experience.start_date + date_difference,
          end_date: experience.end_date + date_difference
        )
        new_obj.save
      end

      # copy the bingo! games
      bingo_games.each do |bingo_game|
        new_obj = new_course.bingo_games.new(
          topic: bingo_game.topic,
          description: bingo_game.description,
          link: bingo_game.link,
          source: bingo_game.source,
          group_option: bingo_game.group_option,
          individual_count: bingo_game.individual_count,
          lead_time: bingo_game.lead_time,
          group_discount: bingo_game.group_discount,
          project: proj_hash[bingo_game.project],
          start_date: bingo_game.start_date + date_difference,
          end_date: bingo_game.end_date + date_difference
        )
        new_obj.save
      end

      new_course.save
    end
    new_course
  end

  def add_user_by_email(user_email, instructor = false)
    ret_val = false
    if EmailValidator.valid? user_email
      role = instructor ? Roster.roles[:instructor] : Roster.roles[:invited_student]
      # Searching for the student and:
      user = User.joins(:emails).where(emails: { email: user_email }).take

      passwd = (0...8).map { rand(65..90).chr }.join

      if user.nil?
        user = User.create(email: user_email, admin: false, timezone: timezone, password: passwd, school: school)
      end

      unless user.nil?
        existing_roster = Roster.where(course: self, user: user).take
        if existing_roster.nil?
          Roster.create(user: user, course: self, role: role)
          ret_val = true
        else
          if instructor || existing_roster.enrolled_student!
            existing_roster.role = role
            existing_roster.save
            if existing_roster.errors.empty?
              ret_val = true
            else
              logger.debug existing_roster.errors.full_messages
            end
          end
        end
        # TODO: Let's add course invitation emails here in the future
      end
    end
    ret_val
  end

  def add_students_by_email(student_emails)
    count = 0
    student_emails.split(/[\s,]+/).each do |email|
      count += 1 if add_user_by_email email
    end
    count
  end

  def add_instructors_by_email(instructor_emails)
    count = 0
    instructor_emails.split(/[\s,]+/).each do |email|
      count += 1 if add_user_by_email(email, true)
    end
    count
  end

  def enrolled_students
    rosters.includes(user: [:emails]).enrolled.collect(&:user)
  end

  def instructors
    rosters.instructor.collect(&:user)
  end

  private

  # Validation check code
  def date_sanity
    if start_date.blank? || end_date.blank?
      errors.add(:start_dow, 'The start date is required') if start_date.blank?
      errors.add(:end_dow, 'The end date is required') if end_date.blank?
    elsif start_date > end_date
      errors.add(:start_dow, 'The start date must come before the end date')
    end
    errors
  end

  # TODO: - check for date sanity of experiences and projects
  def activity_date_check
    experiences.reload.each do |experience|
      if experience.start_date < start_date
        msg = errors[:start_date].blank? ? '' : errors[:start_date]
        msg = "Experience '#{experience.name}' currently starts before this course does"
        msg += " (#{experience.start_date} < #{start_date})."
        errors.add(:start_date, msg)
      end
      next unless experience.end_date.change(sec: 0) > end_date
      msg = errors[:end_date].blank? ? '' : errors[:end_date]
      msg = "Experience '#{experience.name}' currently ends after this course does"
      msg += " (#{experience.end_date} > #{end_date})."
      errors.add(:end_date, msg)
    end
    projects.reload.each do |project|
      if project.start_date < start_date
        msg = errors[:start_date].blank? ? '' : errors[:start_date]
        msg += "Project '#{project.name}' currently starts before this course does"
        msg += " (#{project.start_date} < #{start_date})."
        errors.add(:start_date, msg)
      end
      next unless project.end_date.change(sec: 0) > end_date
      msg = errors[:end_date].blank? ? '' : errors[:end_date]
      msg = "Project '#{project.name}' currently ends after this course does"
      msg += " (#{project.end_date} > #{end_date})."
      errors.add(:end_date, msg)
    end
    bingo_games.reload.each do |bingo_game|
      if bingo_game.start_date < start_date
        msg = errors[:start_date].blank? ? '' : errors[:start_date]
        msg = "Bingo! '#{bingo_game.topic}' currently starts before this course does "
        msg += " (#{bingo_game.start_date} < #{start_date})."
        errors.add(:start_date, msg)
      end
      next unless bingo_game.end_date.change(sec: 0) > end_date
      msg = errors[:end_date].blank? ? '' : errors[:end_date]
      msg = "Bingo! '#{bingo_game.topic}' currently ends after this course does "
      msg += " (#{bingo_game.end_date} > #{end_date})."
      errors.add(:end_date, msg)
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
    # TODO: must handle changing timezones at some point

    # TZ corrections
    if (start_date_changed? || timezone_changed?) && start_date.present?
      d = start_date.utc
      new_date = course_tz.local(d.year, d.month, d.day).beginning_of_day
      self.start_date = new_date
    end

    if (end_date_changed? || timezone_changed?) && end_date.present?
      new_date = course_tz.local(end_date.year, end_date.month, end_date.day)
      self.end_date = new_date.end_of_day.change(sec: 0)
    end

    if timezone_changed? && timezone_was.present?
      orig_tz = ActiveSupport::TimeZone.new(timezone_was)

      Course.transaction do
        projects.reload.each do |project|
          d = orig_tz.parse(project.start_date.to_s)
          d = course_tz.local(d.year, d.month, d.day)
          project.start_date = d.beginning_of_day

          d = orig_tz.parse(project.end_date.to_s)
          d = course_tz.local(d.year, d.month, d.day)
          project.end_date = d.end_of_day
          # {project.end_date}\n\n"
          project.save(validate: false)
        end
        experiences.reload.each do |experience|
          d = orig_tz.parse(experience.start_date.to_s)
          d = course_tz.local(d.year, d.month, d.day)
          experience.start_date = d.beginning_of_day

          d = orig_tz.parse(experience.end_date.to_s)
          d = course_tz.local(d.year, d.month, d.day)
          experience.end_date = d.end_of_day
          experience.save(validate: false)
        end
        bingo_games.each do |bingo_game|
          d = orig_tz.parse(bingo_game.start_date.to_s)
          d = course_tz.local(d.year, d.month, d.day)
          bingo_game.start_date = d.beginning_of_day

          d = orig_tz.parse(bingo_game.end_date.to_s)
          d = course_tz.local(d.year, d.month, d.day)
          bingo_game.end_date = d.end_of_day
          bingo_game.save(validate: false)
        end
      end
    end
  end
end

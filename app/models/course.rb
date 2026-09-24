# frozen_string_literal: true

require 'faker'
class Course < ApplicationRecord
  belongs_to :school, inverse_of: :courses, counter_cache: true
  has_many :projects, inverse_of: :course, dependent: :destroy, autosave: true
  has_many :rosters, inverse_of: :course, dependent: :destroy, autosave: true
  has_many :bingo_games, inverse_of: :course, dependent: :destroy, autosave: true
  has_many :candidate_lists, through: :bingo_games
  has_many :candidates, through: :candidate_lists
  has_many :concepts, through: :candidate_lists
  has_many :users, through: :rosters
  belongs_to :consent_form, counter_cache: true, inverse_of: :courses, optional: true
  has_many :assignments, inverse_of: :course, autosave: true, dependent: :destroy

  has_many :experiences, inverse_of: :course, dependent: :destroy, autosave: true

  delegate :active, to: :consent_form, prefix: true

  validates :timezone, :start_date, :end_date, presence: true
  validates :name, presence: true
  validate :date_sanity
  validate :activity_date_check

  before_validation :timezone_adjust_comprehensive
  before_create :anonymize

  def pretty_name( anonymous = false )
    if anonymous
      "#{anon_name} (#{anon_number})"
    elsif number.present?
      "#{name} (#{number})"
    else
      name
    end
  end

  def get_activities
    activities = projects.where( deleted: false ).to_a
    activities.concat bingo_games.where( deleted: false )
    activities.concat experiences.where( deleted: false )
    activities.concat assignments.where( deleted: false )

    activities.sort_by( &:end_date )
  end

  def get_consent_log( user: )
    log = nil

    unless consent_form_id.nil? || !consent_form.is_active?
      log = consent_form.consent_logs
                        .find_by( user: )
      if log.nil?
        log = user.consent_logs.create(
          consent_form_id:,
          presented: false
        )
      end
    end
    log
  end

  def get_name( anonymous = false )
    anonymous ? anon_name : name
  end

  def get_number( anonymous = false )
    anonymous ? anon_number : number
  end

  def set_user_role( user, role )
    roster = rosters.find_by( user: )
    roster = Roster.new( user:, course: self ) if roster.nil?
    roster.role = role
    roster.save
    logger.debug roster.errors.full_messages unless roster.errors.empty?
  end

  def drop_student( user )
    roster = Roster.find_by( user:, course: self )
    roster.role = Roster.roles[:dropped_student]
    roster.save
  end

  def get_user_role( user )
    roster = rosters.find_by( user: )
    roster&.role
  end

    def copy_from_template( new_start: )
    safe_timezone = timezone.presence || school&.timezone.presence || 'UTC'
    course_tz = ActiveSupport::TimeZone.new( safe_timezone )

    local_old_start = start_date.in_time_zone( course_tz ).to_date
    local_new_start = new_start.in_time_zone( course_tz ).to_date
    date_difference = ( local_new_start - local_old_start ).to_i

    new_course = nil

    Course.transaction do
      # 1. Establish absolute calendar dates to prevent boundary drift
      target_course_start = local_new_start
      target_course_end   = end_date.in_time_zone( course_tz ).to_date + date_difference

      new_course = school.courses.create!(
        name: "Copy of #{name}",
        number: "Copy of #{number}",
        description:,
        timezone: safe_timezone,
        start_date: course_tz.local( target_course_start.year, target_course_start.month,
                                     target_course_start.day ).beginning_of_day,
        end_date: course_tz.local( target_course_end.year, target_course_end.month,
                                   target_course_end.day ).end_of_day.change( sec: 0 )
      )

      # copy the faculty rosters
      rosters.faculty.each do | roster |
        new_course.rosters.create!(
          role: roster.role,
          user: roster.user
        )
      end

      # copy the projects
      proj_hash = {}
      projects.each do | project |
        new_obj = new_course.projects.create!(
          name: project.name,
          style: project.style,
          factor_pack: project.factor_pack,
          start_date: project.start_date.advance( days: date_difference ),
          end_date: project.end_date.advance( days: date_difference ),
          start_dow: project.start_dow,
          end_dow: project.end_dow
        )
        proj_hash[project] = new_obj
      end

      # copy the experiences
      experiences.each do | experience |
        new_course.experiences.create!(
          name: experience.name,
          start_date: experience.start_date.advance( days: date_difference ),
          end_date: experience.end_date.advance( days: date_difference )
        )
      end

      # copy the bingo! games
      bingo_games.each do | bingo_game |
        new_course.bingo_games.create!(
          topic: bingo_game.topic,
          description: bingo_game.description,
          source: bingo_game.source,
          group_option: bingo_game.group_option,
          individual_count: bingo_game.individual_count,
          lead_time: bingo_game.lead_time,
          group_discount: bingo_game.group_discount,
          project: proj_hash[bingo_game.project],
          start_date: bingo_game.start_date.advance( days: date_difference ),
          end_date: bingo_game.end_date.advance( days: date_difference )
        )
      end

      # copy the assignments
      assignments.each do | assignment |
        new_course.assignments.create!(
          name: assignment.name,
          description: assignment.description,
          rubric: assignment.rubric,
          file_sub: assignment.file_sub,
          link_sub: assignment.link_sub,
          text_sub: assignment.text_sub,
          passing: assignment.passing,
          group_enabled: assignment.group_enabled,
          project: proj_hash[assignment.project]
        )
      end
    end
    new_course
  end

    def copy_from_template( new_start: )
    safe_timezone = timezone.presence || school&.timezone.presence || 'UTC'
    course_tz = ActiveSupport::TimeZone.new( safe_timezone )

    local_old_start = start_date.in_time_zone( course_tz ).to_date
    local_new_start = new_start.in_time_zone( course_tz ).to_date
    date_difference = ( local_new_start - local_old_start ).to_i

    new_course = nil

    Course.transaction do
      # 1. Establish absolute calendar dates to prevent boundary drift
      target_course_start = local_new_start
      target_course_end   = end_date.in_time_zone( course_tz ).to_date + date_difference

      new_course = school.courses.create!(
        name: "Copy of #{name}",
        number: "Copy of #{number}",
        description:,
        timezone: safe_timezone,
        start_date: course_tz.local( target_course_start.year, target_course_start.month,
                                     target_course_start.day ).beginning_of_day,
        end_date: course_tz.local( target_course_end.year, target_course_end.month,
                                   target_course_end.day ).end_of_day.change( sec: 0 )
      )

      # copy the faculty rosters
      rosters.faculty.each do | roster |
        new_course.rosters.create!(
          role: roster.role,
          user: roster.user
        )
      end

      # copy the projects
      proj_hash = {}
      projects.each do | project |
        p_start = project.start_date.advance( days: date_difference ).in_time_zone( course_tz )
        p_end   = project.end_date.advance( days: date_difference ).in_time_zone( course_tz )

        new_obj = new_course.projects.build(
          name: project.name,
          style: project.style,
          factor_pack: project.factor_pack,
          start_date: p_start,
          end_date: p_end,
          start_dow: project.start_dow,
          end_dow: project.end_dow
        )
        new_obj.save!( validate: false )
        proj_hash[project] = new_obj
      end

      # copy the experiences
      experiences.each do | experience |
        e_start = experience.start_date.advance( days: date_difference ).in_time_zone( course_tz )
        e_end   = experience.end_date.advance( days: date_difference ).in_time_zone( course_tz )

        new_exp = new_course.experiences.build(
          name: experience.name,
          start_date: e_start,
          end_date: e_end
        )
        new_exp.save!( validate: false )
      end

      # copy the bingo! games
      bingo_games.each do | bingo_game |
        b_start = bingo_game.start_date.advance( days: date_difference ).in_time_zone( course_tz )
        b_end   = bingo_game.end_date.advance( days: date_difference ).in_time_zone( course_tz )

        new_bingo = new_course.bingo_games.build(
          topic: bingo_game.topic,
          description: bingo_game.description,
          source: bingo_game.source,
          group_option: bingo_game.group_option,
          individual_count: bingo_game.individual_count,
          lead_time: bingo_game.lead_time,
          group_discount: bingo_game.group_discount,
          project: proj_hash[bingo_game.project],
          start_date: b_start,
          end_date: b_end
        )
        new_bingo.save!( validate: false )
      end

      # copy the assignments
      assignments.each do | assignment |
        a_start = assignment.start_date.advance( days: date_difference ).in_time_zone( course_tz )
        a_end   = assignment.end_date.advance( days: date_difference ).in_time_zone( course_tz )

        new_assignment = new_course.assignments.build(
          name: assignment.name,
          description: assignment.description,
          start_date: a_start,
          end_date: a_end,
          rubric: assignment.rubric,
          file_sub: assignment.file_sub,
          link_sub: assignment.link_sub,
          text_sub: assignment.text_sub,
          passing: assignment.passing,
          group_enabled: assignment.group_enabled,
          project: proj_hash[assignment.project]
        )
        new_assignment.save!( validate: false )
      end
    end
    new_course
  end


  def diversity_analysis( member_count: 4 )
    students = rosters.enrolled.collect( &:user )
    combinations = students.combination( member_count ).size
    max_actual = 1000
    results = {
      student_count: students.size,
      combinations:,
      actual: max_actual >= combinations
    }

    options = []
    if results[:actual]
      students.combination( member_count ).each do | members |
        group_score = Group.calc_diversity_score_for_group( users: members )
        options << group_score
      end
    else
      max_actual.times do
        members = students.sample member_count
        group_score = Group.calc_diversity_score_for_group( users: members )
        options << group_score
      end
    end
    options = options.reject { | n | n < 1 }.sort

    results[:min] = options.first
    results[:max] = options.last
    results[:average] = options.inject { | sum, el | sum + el } / options.size.to_f
    results[:class_score] = Group.calc_diversity_score_for_group( users: students )

    results
  end

  def add_user_by_email( user_email, instructor = false )
    ret_val = false

    if EmailAddress.valid? user_email
      role = instructor ? Roster.roles[:instructor] : Roster.roles[:invited_student]
      # Searching for the student and:
      user = User.joins( :emails ).find_by( emails: { email: user_email } )

      passwd = SecureRandom.alphanumeric( 10 ) # creates a password

      if user.nil?
        user = User.create( email: user_email, admin: false, timezone:, password: passwd, school: )
        logger.debug user.errors.full_messages unless user.errors.empty?
      end

      unless user.nil?
        existing_roster = Roster.find_by( course: self, user: )
        if existing_roster.nil?
          Roster.create( user:, course: self, role: )
          ret_val = true
        elsif instructor || existing_roster.enrolled_student!
          existing_roster.role = role
          existing_roster.save
          if existing_roster.errors.empty?
            ret_val = true
          else
            logger.debug existing_roster.errors.full_messages
          end
        end
        # TODO: Let's add course invitation emails here in the future
      end
    end
    ret_val
  end

  def add_students_by_email( student_emails )
    count = 0
    student_emails.split( /[\s,]+/ ).each do | email |
      count += 1 if add_user_by_email email
    end
    count
  end

  def add_instructors_by_email( instructor_emails )
    count = 0
    instructor_emails.split( /[\s,]+/ ).each do | email |
      count += 1 if add_user_by_email( email, true )
    end
    count
  end

  def enrolled_students
    rosters.includes( user: [:emails] ).enrolled.collect( &:user )
  end

  def instructors
    rosters.instructor.collect( &:user )
  end

  private

  # Validation check code
  def date_sanity
    if start_date.blank? || end_date.blank?
      errors.add( :start_dow, 'The start date is required' ) if start_date.blank?
      errors.add( :end_dow, 'The end date is required' ) if end_date.blank?
    elsif start_date > end_date
      errors.add( :start_dow, 'The start date must come before the end date' )
    end
    errors
  end

  def activity_date_check
    get_activities.each do | activity |
      # Safely fall back to get_name if .name doesn't exist (like in BingoGame)
      activity_name = activity.respond_to?(:name) ? activity.name : activity.get_name(false)

      if activity.start_date.present? && activity.start_date < start_date
        msg = "Activity '#{activity_name}' (#{activity.type}) currently starts before this course does"
        msg += " (#{activity.start_date} < #{start_date})."
        errors.add( :start_date, msg )
      end

      next unless activity.end_date.present? && activity.end_date.change( sec: 0 ) > end_date.change( sec: 0 )

      msg = "Activity '#{activity_name}' currently ends after this course does"
      msg += " (#{activity.end_date} > #{end_date})."
      errors.add( :end_date, msg )
    end
  end


  def anonymize
    levels = %w[Beginning Intermediate Advanced]
    self.anon_name ||= "#{levels.sample} #{Faker::Company.industry}"
    dpts = %w[BUS MED ENG RTG MSM LEH EDP
              GEO IST MAT YOW GFB RSV CSV MBV]
    self.anon_number ||= "#{dpts.sample}-#{rand( 100..700 )}"
    # Data offset in days
    self.anon_offset ||= - Random.rand( 1000 ).days.to_i + 35
  end

  def timezone_adjust_comprehensive
    course_tz = ActiveSupport::TimeZone.new( timezone || 'UTC' )

    # TZ corrections
    if ( start_date_changed? || timezone_changed? ) && start_date.present?
      d = start_date.in_time_zone( course_tz )
      self.start_date = course_tz.local( d.year, d.month, d.day ).beginning_of_day
    end

    if ( end_date_changed? || timezone_changed? ) && end_date.present?
      d = end_date.in_time_zone( course_tz )
      self.end_date = course_tz.local( d.year, d.month, d.day ).end_of_day.change( sec: 0 )
    end

    return unless timezone_changed? && new_record?

    orig_tz = ActiveSupport::TimeZone.new( timezone_was || timezone || 'UTC' )

    Course.transaction do
      get_activities.each do | activity |
        old_start = activity.start_date.in_time_zone( orig_tz )
        old_end = activity.end_date.in_time_zone( orig_tz )

        activity.start_date = course_tz.local( old_start.year, old_start.month, old_start.day ).beginning_of_day
        activity.end_date = course_tz.local( old_end.year, old_end.month, old_end.day ).end_of_day.change( sec: 0 )

        activity.save!( validate: false ) if persisted?
      end
    end
  end
end

# frozen_string_literal: true

require 'forgery'
class Project < ApplicationRecord
  after_save :build_assessment

  belongs_to :course, inverse_of: :projects
  belongs_to :style, inverse_of: :projects
  belongs_to :factor_pack, inverse_of: :projects, optional: true
  has_many :groups, inverse_of: :project, dependent: :destroy
  has_many :bingo_games, inverse_of: :project, dependent: :destroy
  has_many :assessments, inverse_of: :project, dependent: :destroy
  has_many :installments, through: :assessments
  belongs_to :consent_form, inverse_of: :projects, optional: true

  has_many :users, through: :groups
  has_many :factors, through: :factor_pack

  validates :name, :end_dow, :start_dow, presence: true
  validates :end_date, :start_date, presence: true
  before_create :anonymize

  before_validation :timezone_adjust

  validates :start_dow, :end_dow, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 6
  }

  # Let's be sure the dates are valid
  validate :date_sanity
  validate :dates_within_course
  validate :activation_status

  def group_for_user(user)
    if id == -1 # This hack supports demonstration of group term lists
      Group.new(name: 'SuperStars', users: [user])
    else
      groups.joins(:users).where(users: { id: user.id }).take
    end
  end

  def get_performance(user)
    installments_count = installments.where(user: user).count
    assessments.count == 0 ? 100 : 100 * installments_count / assessments.count
  end

  #TODO Not ideal structuring for UI
  def get_activity_begin
    start_date
  end

  def get_type
    I18n.t(:project)
  end

  def is_for_research?
    consent_form.present? && consent_form.is_active?
  end

  def enrolled_user_rosters
    course.rosters.enrolled
  end

  def number_of_weeks
    (end_date - start_date).divmod(7)[0]
  end

  def get_user_appearance_counts
    Project.get_occurence_count_hash users
  end

  def get_group_appearance_counts
    Project.get_occurence_count_hash groups
  end

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  def get_activity_on_date(date:, anon:)
    day = date.wday
    o_string = get_name(anon)
    add_string = ''
    add_string = if has_inside_date_range?
                   if day < start_dow || day > end_dow
                     ' (work)'
                   else
                     ' (SAPA)'
                                end
                 else
                   if day < end_dow && day > start_dow
                     ' (work)'
                   else
                     ' (SAPA)'
                                end
                 end
    o_string + add_string
  end

  def self.get_occurence_count_hash(input_array)
    dup_hash = Hash.new(0)
    input_array.each { |v| dup_hash.store(v.id, dup_hash[v.id] + 1) }
    dup_hash
  end

  # If the date range wraps from Saturday to Sunday, it's not inside.
  def has_inside_date_range?
    has_inside_date_range = false
    has_inside_date_range = true if start_dow <= end_dow
    has_inside_date_range
  end

  # Check if the assessment is active, if we're in the date range and
  # within the day range.
  def is_available?
    tz = ActiveSupport::TimeZone.new(course.timezone)
    is_available = false
    init_date = tz.parse(DateTime.current.to_s)
    init_day = init_date.wday

    if active &&
       start_date <= init_date && end_date >= init_date
      if has_inside_date_range?
        is_available = true if start_dow <= init_day && end_dow >= init_day
      else

        is_available = true unless init_day < start_dow && end_dow < init_day
       end
    end
    is_available
  end

  def type
    'Self- and Peer-Assessed Project'
  end

  def status_for_user(_user)
    # get some sort of count of completion rates
    'Coming soon'
  end

  def status
    'Coming soon'
  end

  def get_days_applicable
    days = [ ]
    if has_inside_date_range?
      start_dow.upto end_dow do |day_num|
        days << day_num
      end
    else
      start_dow.upto 6 do |day_num|
        days << day_num
      end
      0.upto end_dow do |day_num|
        days << day_num
      end
    end
    days

  end

  def get_events

    events = [
      {
        id: "proj_#{id}",
        title: name,
        start: start_date,
        end: end_date,
        allDay: true,
        backgroundColor: '#999999'
      },
      {
        id: "asmt_#{id}",
        title: "#{name} assessment",
        allDay: true,
        backgroundColor: '#FF9999',
        rrule: {
          freq: 'weekly',
          byweekday: get_days_applicable,
          dtstart: start_date,
          until: end_date,
        }
      }
    ]
  end

  private
  # Validation check code
  def date_sanity
    unless start_date.nil? || end_date.nil?
      if start_date > end_date
        errors.add(:start_dow, 'The start date must come before the end date')
      end
      errors
    end
  end

  def dates_within_course
    unless start_date.nil? || end_date.nil?
      if start_date < course.start_date
        msg = 'The project cannot begin before the course has begun '
        msg += "(#{start_date} < #{course.start_date})"
        errors.add(:start_date, msg)
      end
      if end_date > course.end_date
        msg = 'The project cannot continue after the course has ended '
        msg += "(#{end_date} > #{course.end_date})"
        errors.add(:end_date, msg)
      end
    end
    errors
  end

  def activation_status
    if active_before_last_save && active &&
       (start_dow_changed? || end_dow_changed? ||
        start_date_changed? || end_date_changed? ||
        factor_pack_id_changed? || style_id_changed?)
      self.active = false
    elsif !active_before_last_save && active

      get_user_appearance_counts.each do |user_id, count|
        # Check the users
        user = User.find(user_id)
        if Roster.enrolled.where(user: user, course: course).count < 1
          errors.add(:active, "#{user.name false} does not appear to be enrolled in this course.")
        elsif count > 1
          errors.add(:active, "#{user.name false} appears #{count} times in your project.")
        end
      end
      # Check the groups
      get_group_appearance_counts.each do |group_id, count|
        if count > 1
          group = Group.find(group_id)
          errors.add(:active, "#{group.name false} (group) appears #{count} times in your project.")
        end
      end
      if factor_pack.nil?
        errors.add(:factor_pack, 'Factor Pack must be set before a project can be activated')
      end
      # If this is an activation, we need to set up any necessary weeklies
      Assessment.configure_current_assessment self
    end
    errors
  end

  # Handler for building an assessment, if necessary
  def build_assessment
    # Nothing needs to be done unless we're active
    Assessment.configure_current_assessment self if active?
  end

  private

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)

    # TZ corrections
    if start_date.nil? || start_date.change(hour: 0) == course.start_date.change(hour: 0)
      self.start_date = course.start_date
    elsif start_date_change_to_be_saved
      proc_date = course_tz.local(start_date.year, start_date.month, start_date.day)
      self.start_date = proc_date.beginning_of_day
    end

    if end_date.nil? || end_date.change(hour: 0) == course.end_date.change(hour: 0)
      self.end_date = course.end_date
    elsif end_date_change_to_be_saved
      proc_date = course_tz.local(end_date.year, end_date.month, end_date.day)
      self.end_date = proc_date.end_of_day.change(sec: 0)
    end
  end

  def anonymize
    self.anon_name = "#{rand < rand ? Forgery::Address.country : Forgery::Name.location} #{Forgery::Name.job_title}"
  end
end

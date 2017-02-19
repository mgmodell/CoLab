class Project < ActiveRecord::Base
  after_save :build_assessment

  belongs_to :course, inverse_of: :projects
  belongs_to :style, inverse_of: :projects
  has_many :groups, inverse_of: :project
  has_many :assessments, inverse_of: :project
  belongs_to :course, inverse_of: :projects
  belongs_to :consent_form, inverse_of: :projects
  belongs_to :factor_pack, inverse_of: :projects

  has_many :users, through: :groups
  has_many :factors, through: :factor_pack

  validates :name, :end_dow, :start_dow, presence: true
  validates :end_date, :start_date, presence: true

  after_validation :timezone_adjust

  validates :start_dow, :end_dow, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 6
  }

  # Let's be sure the dates are valid
  validate :date_sanity
  validate :dates_within_course
  validate :activation_status

  def group_for_user user
    self.groups.joins( :users ).where( users: { id: user.id } ).take
  end

  def is_for_research?
    !consent_form.nil?
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
    is_available = false
    init_time = DateTime.current.in_time_zone
    init_day = init_time.wday
    init_date = init_time.to_date

    if active &&
       start_date < init_date && end_date > init_date
      if has_inside_date_range?
        is_available = true if start_dow <= init_day && end_dow >= init_day
      else

        is_available = true unless init_day < start_dow && end_dow < init_day
       end
    end
    logger.debug is_available
    is_available
  end

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
        errors.add(:start_date, 'The project cannot begin before the course has begun')
      end
      if end_date > course.end_date
        errors.add(:end_date, 'The project cannot continue after the course has ended')
      end
    end
    errors
  end

  def activation_status
    if active_was && active
      errors.add(:active, 'You cannot make changes to an active project. Please deactivate it first.')
    elsif !active_was && active

      get_user_appearance_counts.each do |user_id, count|
        # Check the users
        user = User.find(user_id)
        if Roster.enrolled.where(user: user, course: course).count < 1
          errors.add(:active, "#{user.name} is does not appear to be enrolled in this course.")
        elsif count > 1
          errors.add(:active, "#{user.name} appears #{count} times in your project.")
        end
      end
      # Check the groups
      get_group_appearance_counts.each do |group_id, count|
        if count > 1
          group = Group.find(group_id)
          errors.add(:active, "#{group.name} (group) appears #{count} times in your project.")
        end
      end
      # If this is an activation, we need to set up any necessary weeklies
    end
    errors
  end

  # Handler for building an assessment, if necessary
  def build_assessment
    # Nothing needs to be done unless we're active
    Assessment.build_new_assessment self if active? && is_available?
  end

  # after_find do |user|
  #  user.timezone_adjust
  # end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)
    self.start_date -= course_tz.utc_offset if start_date_changed?

    self.end_date -= course_tz.utc_offset if end_date_changed?
  end
end

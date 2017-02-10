class Experience < ActiveRecord::Base
  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience

  validates :name, :end_date, :start_date, presence: true

  validate :date_sanity
  after_validation :timezone_adjust

  scope :still_open, -> { where('experiences.start_date <= ? AND experiences.end_date >= ?', DateTime.current, DateTime.current) }

  def get_user_reaction(user)
    reaction = reactions.where(user: user).take
    if reaction.nil?
      reaction = Reaction.new
      reaction.user = user
      reaction.experience = self
    end
    reaction
  end

  def get_narrative_counts
    reactions.group(:narrative).count.to_a.sort! { |x, y| x[1] <=> y[1] }
  end

  def get_scenario_counts
    reactions.joins(narrative: :scenario).group(:scenario_id).count.to_a.sort! { |x, y| x[1] <=> y[1] }
  end

  def date_sanity
    unless start_date.nil? || end_date.nil?
      if start_date > end_date
        errors.add(:start_date, 'The start date must come before the end date')
      end
      errors
    end
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)
    self.start_date = start_date.beginning_of_day - course_tz.utc_offset if start_date_changed?
    self.end_date = end_date.end_of_day - course_tz.utc_offset if end_date_changed?
  end
end

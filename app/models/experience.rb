class Experience < ActiveRecord::Base
  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience

  validates :name, :end_date, :start_date, presence: true

  validate :date_sanity
  after_validation :timezone_adjust

  scope :still_open, -> { where( 'experiences.end_date >= ? AND experiences.start_date <= ?', DateTime.current, DateTime.current ) }

  def get_user_reaction( user ) 
    reaction = reactions.where( user: user )
    if reaction.count == 0
      return reaction[ 0 ]
    elsif
      r = Reaction.new
      r.user = user
      r.experience = self
      return r
    else
      logger.debug "We've got too many reactions recorded for this user"
    end
  end

  def get_scenario_proportions
    proportions = { }
    reactions.each do |reaction|
      current_value = proportions{ reaction.narrative.scenario }
      if current_value.nil?
        proportions[ reaction.narrative.scenario ] = 1
      else
        proportions[ reaction.narrative.scenario ] = current_value + 1
      end
    end
    return proportions
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
    self.start_date -= course_tz.utc_offset if start_date_changed?
    self.end_date -= course_tz.utc_offset if end_date_changed?
  end
end

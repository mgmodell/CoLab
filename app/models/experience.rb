class Experience < ActiveRecord::Base
  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience

  validates :name, :end_date, :start_date, presence: true

  validate :date_sanity
  after_validation :timezone_adjust

  scope :still_open, -> {
    where('experiences.start_date <= ? AND experiences.end_date >= ?',
          DateTime.current, DateTime.current)
  }

  def get_user_reaction(user)
    reaction = reactions.where(user: user).take

    reaction = Reaction.create(user: user, experience: self, instructed: false) if reaction.nil?
    reaction
  end

  def get_least_reviewed_narrative(include_ids = [])
    narrative_counts = if include_ids.empty?
                         reactions.group(:narrative_id).count
                       else
                         reactions
                           .where('narrative_id IN (?)', include_ids)
                           .group(:narrative_id).count
                       end

    narrative = NilClass
    if narrative_counts.empty?
      narrative = if include_ids.empty?
                    Narrative.take
                  else
                    Narrative.where('id IN (?)', include_ids).take
                  end
    elsif narrative_counts.count < Narrative.all.count
      
      scenario_counts = reactions.joins(:narrative).group(:scenario_id).count
      if scenario_counts.count < Scenario.all.count
        narrative = Narrative.where('scenario_id NOT IN (?)', scenario_counts.collect { |x| x[0] }).take
      else
        narrative = Narrative.where('id NOT IN (?)', narrative_counts.collect { |x| x[0] }).take
      end
    else
      narrative = Narrative.find(narrative_counts.sort { |x, y| x[1] <=> y[1] }[0][0])
    end
    narrative
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

class Reaction < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :reactions
  belongs_to :narrative
  belongs_to :user
  belongs_to :experience, inverse_of: :reactions

  has_many :diagnoses, inverse_of: :reaction

  validates :narrative, presence: true
  validate :thorough_completion

  def next_week
    week = nil

    # If we haven't yet decided on a narrative....
    if narrative.nil?

      found_narrative = NilClass
      # If we've already been assigned at least one reaction
      if user.reactions.count > 0 && user.reactions.count < Narrative.all.count
        if user.reactions.count < Scenario.all.count
          # If they haven't yet been assigned all possible scenarios
          available_scenarios = user.reactions.narratives.group(:scenario_id)
          possible_narratives = Narrative.where('scenario_id in (?)', available_scenarios.to_a)
          found_narrative = experience.get_least_reviewed_narrative(possible_narratives.collect(&:id))

        else
          # If they've been assigned all scenarios, but not all narratives
          available_scenarios = user.reactions.narratives.group(narratives: :id)
          possible_narratives = Narrative.where('id in (?)', available_scenarios.to_a)
          found_narrative = experience.get_least_reviewed_narrative(possible_narratives.collect(&:id))

        end

      # interrogate the user for their existing reactions
      # check the extant proportions of the experience
      # select a scenario/narrative
      else
        found_narrative = experience.get_least_reviewed_narrative
      end
      self.narrative = found_narrative
      week = narrative.weeks.order('weeks.week_num').first
    else
      previous_diagnosis = diagnoses.joins(:week).order('weeks.week_num DESC').first
      if previous_diagnosis.nil?
        week = narrative.weeks.where(weeks: { week_num: 1 }).first
      else
        week = Week.where(narrative: previous_diagnosis.reaction.narrative, week_num: previous_diagnosis.week.week_num + 1).first
      end
    end
    week
  end

  def thorough_completion
    if !self.behavior.nil? && self.improvements.blank?
        errors.add(:improvements, 'Reflection on possible improvements is required' )
    end
    errors
  end

end

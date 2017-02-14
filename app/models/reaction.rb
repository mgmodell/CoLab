class Reaction < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :reactions
  belongs_to :narrative
  belongs_to :user
  belongs_to :experience, inverse_of: :reactions

  has_many :diagnoses, inverse_of: :reaction

  validates :narrative, presence: true

  def next_week
    week = nil
    
    # If we haven't yet decided on a narrative....
    if narrative.nil?

      found_narrative = NilClass
      # If we've already been assigned at least one reaction
      if user.reactions.count > 0 && user.reactions.count < Narrative.all.count
        if user.reactions.count < Scenario.all.count
        # If they haven't yet been assigned all possible scenarios
          available_scenarios = user.reactions.narratives.group( :scenario_id )
          possible_narratives = Narrative.where( "scenario_id in (?)", available_scenarios.to_a )
          found_narrative = experience.get_least_reviewed_narrative( possible_narratives.collect{ |x| x.id } )

        else
        # If they've been assigned all scenarios, but not all narratives
          available_scenarios = user.reactions.narratives.group( narratives: :id )
          possible_narratives = Narrative.where( "id in (?)", available_scenarios.to_a )
          found_narrative = experience.get_least_reviewed_narrative( possible_narratives.collect{ |x| x.id } )

        end

      # interrogate the user for their existing reactions
      # check the extant proportions of the experience
      # select a scenario/narrative
      else
        found_narrative = experience.get_least_reviewed_narrative
      end
      self.narrative = found_narrative
      week = narrative.weeks.order(:week_num).first
    else
      previous_week = diagnoses.joins(:week).order(week_num: :desc).take
      week = Week.where(narrative: previous_week.narrative, week_num: previous_week.week_num + 1).to_a
    end
  end
end

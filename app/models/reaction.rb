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

      # If we've already been assigned at least one reaction
      if user.reactions.count > 0
        if user.reactions.count < Scenario.all.count
          # If they haven't yet been assigned all possible scenarios
        elsif user.reactions.narratives.count < Narrative.all.count
          # If they've been assigned all scenarios, but not all narratives
        else
          # Choose the least hit scenario in this Experience
          # TODO: Review this.
          experience.get_scenario_counts.first[0]

        end
      # interrogate the user for their existing reactions
      # check the extant proportions of the experience
      # select a scenario/narrative
      else
        #TODO: Fix this logic
        narrative_counts = experience.get_narrative_counts
        if narrative_counts.last[0]
        self.narrative = narrative_counts[0][0]
      end
      week = narrative.weeks.order(:week_num, :asc).take
    else
      previous_week = diagnoses.joins(:week).order(week_num: :desc).take
      week = Week.where(narrative: previous_week.narrative, week_num: previous_week.week_num + 1).to_a
    end
  end
end

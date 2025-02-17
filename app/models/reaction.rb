# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :behavior, inverse_of: :reactions, optional: true
  belongs_to :narrative
  belongs_to :user
  belongs_to :experience, inverse_of: :reactions
  has_one :course, through: :experience

  has_many :diagnoses, inverse_of: :reaction, dependent: :destroy

  validate :thorough_completion

  validates :other_name, length: { maximum: 255 }

  def assign_narrative
    return unless narrative.nil?

    # If we've already been assigned at least one reaction
    # interrogate the user for their existing reactions
    if user.reactions.count.positive? && user.reactions.count < Narrative.all.count
      if user.reactions.where.not( narrative_id: nil ).count < Scenario.all.count
        # If they haven't yet been assigned all possible scenarios
        assigned_scenarios = user.reactions.joins( :narrative ).group( :scenario_id ).count
        possible_narratives = if assigned_scenarios.empty?
                                Narrative.all
                              else
                                Narrative
                                  .where( 'scenario_id NOT IN (?)', assigned_scenarios.keys )
                              end

      else
        # If they've been assigned all scenarios, but not all narratives
        available_scenarios = user.reactions.group( :narrative_id ).where.not( narrative_id: nil ).count
        possible_narratives = Narrative.where( 'id NOT IN (?)', available_scenarios.keys )

      end
      self.narrative = experience.get_least_reviewed_narrative( possible_narratives.collect( &:id ) )

    else
      # check the extant proportions of the experience
      # select a scenario/narrative
      self.narrative = experience.get_least_reviewed_narrative
    end
  end

  def next_week
    week = nil

    # If we haven't yet decided on a narrative....
    if narrative.nil?

      assign_narrative
      week = narrative.weeks.order( 'weeks.week_num' ).first
    else
      previous_diagnosis = diagnoses.joins( :week ).order( 'weeks.week_num DESC' ).first
      week = if previous_diagnosis.nil?
               narrative.weeks.where( weeks: { week_num: 1 } ).first
             else
               Week.where( narrative: previous_diagnosis.reaction.narrative,
                           week_num: previous_diagnosis.week.week_num + 1 ).first
             end
    end
    week
  end

  def thorough_completion
    if !behavior.nil? && improvements.blank?
      errors.add( :improvements, 'Reflection on possible improvements is required' )
    end
    errors
  end

  def status
    if diagnoses.count.zero?
      0
    elsif behavior.present?
      100
    elsif next_week.nil?
      99
    else
      next_week.percent_complete
    end
  end

  delegate :end_date, to: :experience

  delegate :name, to: :experience

  def sim_id
    narrative.id + ( 100 * narrative.scenario.id )
  end
end

# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :behavior, inverse_of: :reactions, optional: true
  belongs_to :narrative, optional: true
  belongs_to :user
  belongs_to :experience, inverse_of: :reactions
  has_one :course, through: :experience

  has_many :diagnoses, inverse_of: :reaction, dependent: :destroy

  validate :thorough_completion

  validates :other_name, length: { maximum: 255 }

  def next_week
    week = nil

    # If we haven't yet decided on a narrative....
    if narrative.nil?

      found_narrative = NilClass
      # If we've already been assigned at least one reaction
      if user.reactions.count.positive? && user.reactions.count < Narrative.all.count
        if user.reactions.count < Scenario.all.count
          # If they haven't yet been assigned all possible scenarios
          assigned_scenarios = user.reactions.joins(:narrative).group(:scenario_id).count
          possible_narratives = Narrative
                                .where('scenario_id NOT IN (?)', assigned_scenarios.keys)

        else
          # If they've been assigned all scenarios, but not all narratives
          available_scenarios = user.reactions.group(:narrative_id).count
          possible_narratives = Narrative.where('id NOT IN (?)', available_scenarios.keys)

        end
        found_narrative = experience.get_least_reviewed_narrative(possible_narratives.collect(&:id))

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
      week = if previous_diagnosis.nil?
               narrative.weeks.where(weeks: { week_num: 1 }).first
             else
               Week.where(narrative: previous_diagnosis.reaction.narrative,
                          week_num: previous_diagnosis.week.week_num + 1).first
             end
    end
    week
  end

  def thorough_completion
    if !behavior.nil? && improvements.blank?
      errors.add(:improvements, 'Reflection on possible improvements is required')
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
    narrative.id + (100 * narrative.scenario.id)
  end
end

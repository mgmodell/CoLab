# frozen_string_literal: true

class CandidateList < ApplicationRecord
  belongs_to :user, inverse_of: :candidate_lists, optional: true
  belongs_to :group, inverse_of: :candidate_lists, optional: true
  belongs_to :bingo_game, inverse_of: :candidate_lists
  has_many :candidates, inverse_of: :candidate_list,
                        dependent: :destroy,
                        autosave: true
  has_many :concepts, through: :candidates
  has_one :course, through: :bingo_game

  belongs_to :current_candidate_list, class_name: 'CandidateList', optional: true
  has_many :archived_candidate_lists, class_name: 'CandidateList', foreign_key: :current_candidate_list_id

  accepts_nested_attributes_for :candidates

  before_save :cull_candidates

  def get_concepts
    concepts.to_a.uniq
  end

  def percent_completed
    100 * candidates.completed.count / expected_count
  end

  def performance
    performance = 0
    if bingo_game.reviewed
      if cached_performance.nil?
        candidates.joins(:candidate_feedback, :concept).completed
                  .group(:concept).maximum('candidate_feedbacks.credit')
                  .each do |concept_max|
          performance += concept_max[1]
        end
        performance /= expected_count
        self.cached_performance = performance
        save
      end
      performance = cached_performance
    end
    performance
  end

  def get_by_feedback(candidate_feedback)
    candidates.where(candidate_feedback:)
  end

  def get_accepted_terms
    candidates.joins(:candidate_feedback).where(candidate_feedbacks: { name: 'Accepted' })
  end

  def get_not_accepted_terms
    candidates.joins(:candidate_feedback).includes(:candidate_feedback).where("candidate_feedbacks.name != 'Accepted' AND candidate_feedbacks.id IS NOT NULL")
  end

  def expected_count
    if is_group
      bingo_game.required_terms_for_contributors(contributor_count)
    else
      bingo_game.individual_count
    end
  end

  def status
    if bingo_game.reviewed
      "Score: #{performance}"
    else
      "Progress: #{percent_completed}"
    end
  end

  delegate :end_date, to: :bingo_game

  delegate :name, to: :bingo_game

  def others_requested_help
    requested_count = 0

    if bingo_game.group_option?
      tentative_group = self.group ||= bingo_game.project.group_for_user(user)
      if bingo_game.group_option? && tentative_group.present?
        tentative_group.users.each do |member_user|
          requested_count += 1 if bingo_game.candidate_list_for_user(member_user).group_requested
        end
      end
      tentative_group.nil? ? 0 : requested_count.to_f / tentative_group.users.count
    else
      false
    end
  end

  private

  def cull_candidates
    candidates.each do |candidate|
      candidate.delete if candidate.term.blank? && candidate.definition.blank?
    end
  end
end

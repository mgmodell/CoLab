# frozen_string_literal: true

class Candidate < ApplicationRecord
  belongs_to :candidate_list, inverse_of: :candidates
  belongs_to :candidate_feedback, inverse_of: :candidates, optional: true
  belongs_to :concept, inverse_of: :candidates,
                       optional: true, counter_cache: true
  belongs_to :user, inverse_of: :candidates
  has_many :bingo_cells, inverse_of: :candidate

  default_scope { order(:filtered_consistent) }
  scope :completed, lambda {
    joins(:candidate_list)
      .where("term != '' AND definition != ''")
      .where('candidate_lists.is_group = 0 OR candidate_lists.group_id IS NOT NULL')
  }
  scope :reviewed, -> { where('candidate_feedback_id > 0 ') }
  scope :acceptable, -> { where( candidate_feedback_id: 1) }

  before_save :clean_data, :update_counts
  validate :concept_assigned

  @@filter = Stopwords::Snowball::Filter.new('en')

  def self.filter
    @@filter
  end

  def clean_data
    self.term = term.nil? ? '' : term.strip.split.map(&:capitalize) * ' '
    self.filtered_consistent = term.nil? ? '' : Candidate.filter.filter(term.strip.split.map(&:downcase)).join(' ')
    definition.strip!
  end

  private

  def update_counts
    if concept.present?
      # Caching solution - candidate mentions are automatic
      concept.bingo_games_count = concept.bingo_games.uniq.size
      concept.courses_count = concept.courses.uniq.size
    end
    if concept_id_changed? && concept_id_was.present?
      # Caching solution - candidate mentions are automatic
      # TODO: verify that the previous owner is updated properly.
      old_concept = Concept.find(concept_id_was)
      old_concept.bingo_games_count = old_concept.bingo_games.uniq.size
      old_concept.courses_count = old_concept.courses.uniq.size
      old_concept.save
    end
  end

  def concept_assigned
    if candidate_list.bingo_game.reviewed && (term.present? || definition.present?)
      unless CandidateFeedback.find(candidate_feedback_id).name.start_with? 'Term'
        if concept_id.nil?
          errors.add(:concept, "Unless there's a problem with the term, you must assign a concept.")
        end
      end
    end
  end
end

# frozen_string_literal: true

class Candidate < ApplicationRecord
  belongs_to :candidate_list, inverse_of: :candidates,
                              counter_cache: true
  belongs_to :candidate_feedback, inverse_of: :candidates, optional: true
  delegate :critique, :credit, to: :candidate_feedback, prefix: true

  belongs_to :concept, inverse_of: :candidates,
                       optional: true, counter_cache: true
  belongs_to :user, inverse_of: :candidates
  has_many :bingo_cells, inverse_of: :candidate, dependent: :nullify

  default_scope { order( :filtered_consistent ) }
  scope :completed, lambda {
    joins( :candidate_list )
      .where( "term != '' AND definition != ''" )
      .where( 'candidate_lists.is_group = 0 OR candidate_lists.group_id IS NOT NULL' )
  }
  scope :reviewed, -> { where( 'candidate_feedback_id > 0 ' ) }
  scope :acceptable, -> { where( candidate_feedback_id: 1 ) }

  before_save :clean_data, :update_counts
  validate :concept_assigned

  @@filter = Stopwords::Snowball::Filter.new( 'en' )

  def self.filter
    @@filter
  end

  def self.clean_term( term )
    Candidate.filter.filter( term.strip.split.map( &:downcase ) ).join( ' ' )
  end

  def clean_data
    self.term = term.nil? ? '' : term.strip.split.map( &:capitalize ) * ' '
    self.filtered_consistent = term.nil? ? '' : Candidate.clean_term( term )
    definition.strip!

    # Reset the performance data on the List
    return unless concept_id_changed? || candidate_feedback_id_changed?

    candidate_list.cached_performance = nil
    candidate_list.save
  end

  private

  def update_counts
    if concept.present?
      # Caching solution - candidate mentions are automatic
      concept.bingo_games_count = concept.bingo_games.uniq.size
      concept.courses_count = concept.courses.uniq.size
    end
    return unless concept_id_changed? && concept_id_was.present?

    # Caching solution - candidate mentions are automatic
    # TODO: verify that the previous owner is updated properly.
    Rails.logger.debug "prior concept: #{concept_id_was}"
    old_concept = Concept.includes( :bingo_games, :courses ).find( concept_id_was )
    old_concept.bingo_games_count = old_concept.bingo_games.uniq.size
    old_concept.courses_count = old_concept.courses.uniq.size
    old_concept.save
  end

  def concept_assigned
    if candidate_list.bingo_game_reviewed && ( term.present? || definition.present? ) && !CandidateFeedback.find( candidate_feedback_id ).term_prob && concept_id.nil?
      errors.add( :concept, "Unless there's a problem with the term, you must assign a concept." )
    end
  end
end

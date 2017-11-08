# frozen_string_literal: true
class Candidate < ActiveRecord::Base
  belongs_to :candidate_list, inverse_of: :candidates
  belongs_to :candidate_feedback, inverse_of: :candidates
  belongs_to :concept, inverse_of: :candidates
  belongs_to :user, inverse_of: :candidates

  default_scope { order(:filtered_consistent) }
  scope :completed, -> { joins(:candidate_list).
                        where("term != '' AND definition != ''").
                        where('candidate_lists.is_group = 0 OR candidate_lists.group_id IS NOT NULL' )}
  scope :reviewed, -> { where('candidate_feedback_id > 0 ') }
  before_save :clean_data
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

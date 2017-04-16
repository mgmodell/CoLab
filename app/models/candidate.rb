# frozen_string_literal: true
class Candidate < ActiveRecord::Base
  belongs_to :candidate_list, inverse_of: :candidates
  belongs_to :candidate_feedback, inverse_of: :candidates
  belongs_to :concept, inverse_of: :candidates

  scope :completed, -> { where("term != '' AND definition != ''") }
  scope :reviewed, -> { where('candidate_feedback_id > 0 ') }
  before_save :trim_data
  validate :concept_assigned

  private

  def trim_data
    term = term.nil? ? '' : term.strip.split.map(&:capitalize) * ' '
    definition.strip!
  end

  def concept_assigned
    if candidate_list.bingo_game.reviewed
      unless CandidateFeedback.find(candidate_feedback_id).name.start_with? 'Term'
        if concept_id.empty?
          errors.add(:concept, "Unless there's a problem with the term, you must assign a concept.")
        end
      end
    end
  end
end

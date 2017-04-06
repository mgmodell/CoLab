# frozen_string_literal: true
class Candidate < ActiveRecord::Base
  belongs_to :candidate_list, inverse_of: :candidates
  belongs_to :candidate_feedback, inverse_of: :candidates
  belongs_to :concept, inverse_of: :candidates

  scope :completed, -> { where("term != '' AND definition != ''") }
end

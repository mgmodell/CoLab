# frozen_string_literal: true

class CandidateFeedback < ApplicationRecord
  translates :name, :definition
  has_many :candidates, inverse_of: :candidate_feedback, dependent: :nullify

  enum critique: { acceptable: 1, def_problem: 2, term_problem: 3 }
  default_scope { order(:name_en) }
end

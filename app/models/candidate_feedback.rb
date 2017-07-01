# frozen_string_literal: true
class CandidateFeedback < ActiveRecord::Base
  translates :name, :definition
  has_many :candidates, inverse_of: :candidate_feedback
end

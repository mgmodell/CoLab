# frozen_string_literal: true

class Criterium < ApplicationRecord
  belongs_to :rubric
  validates :sequence, uniqueness: { scope: :rubric_id }

  delegate :version, to: :rubric
end

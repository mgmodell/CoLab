# frozen_string_literal: true

class Criterium < ApplicationRecord
  belongs_to :rubric

  delegate :version, to: :rubric
end

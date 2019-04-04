# frozen_string_literal: true

class Concept < ApplicationRecord
  has_many :candidates, inverse_of: :concept
  has_many :candidate_lists, through: :candidates
  has_many :bingo_games, through: :candidate_lists
  has_many :courses, through: :bingo_games

  before_save :standardize

  private

  def standardize
    if new_record? || name_changed?
      self.name = name.split.map(&:capitalize).*' '
    end
  end
end

# frozen_string_literal: true

class Concept < ApplicationRecord
  has_many :candidates, inverse_of: :concept, dependent: :nullify
  has_many :candidate_lists, through: :candidates
  has_many :bingo_games, through: :candidate_lists
  has_many :courses, through: :bingo_games

  before_save :standardize

  def self.standardize_name( name: )
    name.split.map( &:capitalize ).*' '
  end

  private

  def standardize
    self.name = Concept.standardize_name name: name if new_record? || name_changed?
  end
end

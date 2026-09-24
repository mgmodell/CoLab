# frozen_string_literal: true

require 'faker'

class School < ApplicationRecord
  has_many :courses, inverse_of: :school, dependent: :destroy
  has_many :bingo_games, through: :courses
  has_many :projects, through: :courses
  has_many :experiences, through: :courses
  has_many :rosters, through: :courses
  has_many :rubrics, inverse_of: :school, dependent: :nullify
  has_many :users, through: :rosters

  before_create :anonymize
  validates :name, :timezone, presence: true

  # Optimized: Query users via roster scopes at the database level rather than loading objects into memory
  def instructors
    users.merge( Roster.instructor ).distinct
  end

  def enrolled_students
    users.merge( Roster.enrolled_student ).distinct
  end

  def get_name( anonymous )
    anonymous ? anon_name : name
  end

  private

  def anonymize
    self.anon_name ||= "#{Faker::Color.color_name} #{Faker::Educator.university}"
  end
end

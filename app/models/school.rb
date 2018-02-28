# frozen_string_literal: true

require 'forgery'
class School < ApplicationRecord
  has_many :courses, inverse_of: :school, dependent: :destroy
  has_many :bingo_games, through: :courses
  has_many :projects, through: :courses
  has_many :experiences, through: :courses
  has_many :rosters, through: :courses

  before_create :anonymize
  validates :name, presence: true

  def instructors
    rosters.instructor.collect(&:user).uniq
  end

  def enrolled_students
    rosters.enrolled_student.collect(&:user).uniq
  end

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  private

  def anonymize
    self.anon_name = "#{rand < rand ? Forgery::Name.location : Forgery::Name.company_name} institute"
  end
end

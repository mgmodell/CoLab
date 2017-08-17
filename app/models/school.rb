# frozen_string_literal: true
require 'forgery'
class School < ActiveRecord::Base
  has_many :courses, inverse_of: :school, dependent: :destroy
  has_many :bingo_games, through: :courses
  has_many :projects, through: :courses
  has_many :experiences, through: :courses
  has_many :rosters, through: :courses

  before_create :anonymize

  def instructors
    rosters.joins(:role).where(roles: { code: 'inst' }).collect(&:user).uniq
  end

  def enrolled_students
    rosters.joins(:role).where(roles: { code: 'enr' }).collect(&:user).uniq
  end

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  private

  def anonymize
    anon_name = "#{rand < rand ? Forgery::Name.location : Forgery::Name.company_name} institute"
  end
end

# frozen_string_literal: true
class School < ActiveRecord::Base
  has_many :courses, inverse_of: :school, dependent: :destroy
  has_many :bingo_games, through: :courses
  has_many :projects, through: :courses
  has_many :experiences, through: :courses
  has_many :rosters, through: :courses

  def instructors
    rosters.joins( :role ).where( roles: { name: "Instructor" } ).collect{ |r| r.user }.uniq
  end

  def enrolled_students
    rosters.joins( :role ).where( roles: { name: "Enrolled Student" } ).collect{ |r| r.user }.uniq
  end
end

# frozen_string_literal: true
class Roster < ActiveRecord::Base
  #belongs_to :role, inverse_of: :rosters
  belongs_to :course, inverse_of: :rosters
  belongs_to :user, inverse_of: :rosters

  enum role: { instructor: 1, assistant: 2, enrolled_student: 3,
              invited_student: 4, declined_student: 5,
              dropped_student: 6 }
  validates_uniqueness_of :user_id, scope: :course_id

  scope :students, -> { where( role: [ roles[:enrolled_student],
                                      roles[:invited_student],
                                      roles[:declined_student] ] ) }
  scope :enrolled, -> { where( role: [ roles[:enrolled_student],
                                      roles[:invited_student] ] ) }

end

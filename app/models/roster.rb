class Roster < ActiveRecord::Base
  belongs_to :role, :inverse_of => :rosters
  belongs_to :course, :inverse_of => :rosters
  belongs_to :user, :inverse_of => :rosters

  validates_uniqueness_of :user_id, :scope => :course_id

  scope :instructorships, -> { joins( :role ).where( "name = ?", "Instructor" ) }
  scope :enrolled, -> { joins( :role ).where( "name = ?", "Enrolled Student" ) }
  scope :awaiting, -> { joins( :role ).where( "name = ?", "Invited Student" ) }
  scope :declined, -> { joins( :role ).where( "name = ?", "Declined Student" ) }
end

class Roster < ActiveRecord::Base
  belongs_to :role
  belongs_to :course
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :course_id

  scope :instructorships, joins( :role ).where( "name = ?", "Instructor" )
  scope :enrolled, joins( :role ).where( "name = ?", "Enrolled Student" )
  scope :awaiting, joins( :role ).where( "name = ?", "Invited Student" )
  scope :declined, joins( :role ).where( "name = ?", "Declined Student" )
end

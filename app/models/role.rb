class Role < ActiveRecord::Base
  has_many :users, inverse_of: :role
  has_many :rosters, inverse_of: :role

  scope :instructor, -> { where(name: 'Instructor') }
  scope :invited, -> { where(name: 'Invited Student') }
  scope :enrolled, -> { where(name: 'Enrolled Student') }
  scope :declined, -> { where(name: 'Declined Student') }
end

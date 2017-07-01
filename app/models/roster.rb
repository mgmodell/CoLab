# frozen_string_literal: true
class Roster < ActiveRecord::Base
  belongs_to :role, inverse_of: :rosters
  belongs_to :course, inverse_of: :rosters
  belongs_to :user, inverse_of: :rosters

  validates_uniqueness_of :user_id, scope: :course_id

  scope :instructorships, -> { joins(:role).where('code = ?', 'inst') }
  scope :students, -> {
    joins(:role).where('code = ? OR code = ? OR code = ?',
                       'enr', 'invt', 'decl')
  }
  scope :enrolled, -> { joins(:role).where('code = ? OR code = ?', 'enr', 'invt') }
  scope :student, -> {
    joins(:role).where('code = ? OR code = ? OR code = ?',
                       'enr', 'invt', 'decl')
  }
  scope :accepted, -> { joins(:role).where('code = ?', 'enr') }
  scope :awaiting, -> { joins(:role).where('code = ?', 'invt') }
  scope :declined, -> { joins(:role).where('code = ?', 'decl') }
  scope :dropped, -> { joins(:role).where('code = ?', 'drop') }
end

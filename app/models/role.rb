# frozen_string_literal: true
class Role < ActiveRecord::Base
  translates :name, :description
  has_many :users, inverse_of: :role
  has_many :rosters, inverse_of: :role

  scope :instructor, -> { where(code: 'inst') }
  scope :invited, -> { where(code: 'invt') }
  scope :enrolled, -> { where(code: 'enr') }
  scope :declined, -> { where(code: 'decl') }
  scope :dropped, -> { where(code: 'drop') }
end

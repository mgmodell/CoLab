# frozen_string_literal: true
class AgeRange < ActiveRecord::Base
  translates :name
  has_many :users, inverse_of: :age_range
end

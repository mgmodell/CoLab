# frozen_string_literal: true
class Theme < ActiveRecord::Base
  translates :name
  has_many :users, inverse_of: :theme
end

# frozen_string_literal: true

class Theme < ApplicationRecord
  translates :name
  has_many :users, inverse_of: :theme
end

# frozen_string_literal: true

class Style < ApplicationRecord
  translates :name
  has_many :projects, inverse_of: :style
end

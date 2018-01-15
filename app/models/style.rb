# frozen_string_literal: true

class Style < ActiveRecord::Base
  translates :name
  has_many :projects, inverse_of: :style
end

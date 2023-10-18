# frozen_string_literal: true

class Gender < ApplicationRecord
  translates :name
  has_many :users, inverse_of: :gender, dependent: :nullify
end

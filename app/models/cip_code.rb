# frozen_string_literal: true

class CipCode < ApplicationRecord
  translates :name
  has_many :users, inverse_of: :cip_codes
end

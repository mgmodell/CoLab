# frozen_string_literal: true

class CipCode < ActiveRecord::Base
  translates :name
  has_many :users, inverse_of: :cip_codes
end

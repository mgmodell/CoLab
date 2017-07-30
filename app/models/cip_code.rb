# frozen_string_literal: true
class CipCode < ActiveRecord::Base
  translates :description
  has_many :users, inverse_of: :cip_codes
end

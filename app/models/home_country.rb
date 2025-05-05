# frozen_string_literal: true

class HomeCountry < ApplicationRecord
  has_many :users, through: :home_state, dependent: :nullify
  has_many :home_states, inverse_of: :home_country, dependent: :destroy

  default_scope { order( :code ) }
end

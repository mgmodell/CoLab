# frozen_string_literal: true
class HomeCountry < ActiveRecord::Base
  has_many :users, through: :home_state
  has_many :home_states, inverse_of: :home_country

  default_scope { order(:code) }
end

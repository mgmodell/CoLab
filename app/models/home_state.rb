# frozen_string_literal: true

class HomeState < ApplicationRecord
  belongs_to :home_country, inverse_of: :home_states
  has_many :users, inverse_of: :home_state, dependent: :nullify

  default_scope { order( :code ) }
end

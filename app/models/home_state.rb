# frozen_string_literal: true

class HomeState < ActiveRecord::Base
  belongs_to :home_country, inverse_of: :home_states
  has_many :users, inverse_of: :home_state

  default_scope { order(:code) }
end

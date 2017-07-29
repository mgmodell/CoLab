class HomeState < ActiveRecord::Base
  belongs_to :homeCountry, inverse_of: :home_states
  has_many :users, inverse_of: :home_state
end

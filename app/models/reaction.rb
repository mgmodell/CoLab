class Reaction < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :reactions
  belongs_to :narrative
  belongs_to :user

  has_many :diagnoses, inverse_of: :reaction
end

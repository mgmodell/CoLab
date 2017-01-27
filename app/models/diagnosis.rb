class Diagnosis < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :diagnoses
  belongs_to :reaction, inverse_of: :diagnoses
  belongs_to :week, inverse_of: :diagnoses

  has_one :user, through: :reaction
end

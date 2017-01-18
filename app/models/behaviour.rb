class Behaviour < ActiveRecord::Base
  has_and_belongs_to_many :behaviour_packs
end

class BehaviourPack < ActiveRecord::Base
  has_and_belongs_to_many :behaviours
  has_many :projects
end

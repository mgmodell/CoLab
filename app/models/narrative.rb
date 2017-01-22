class Narrative < ActiveRecord::Base
   belongs_to :scenario, :inverse_of => :narratives
   has_many :weeks, :inverse_of => :narrative
   has_one :behavior, :through => :scenario
end

class Reaction < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :reactions
  belongs_to :narrative
  belongs_to :user
  belongs_to :experience, inverse_of: :reactions

  has_many :diagnoses, inverse_of: :reaction

  def next_week
    if narrative.nil?
            #interrogate the user for their existing reactions
            #check the extant proportions of the experience
            #select a scenario/narrative
            #hand back week 1
    else
      previous_week = diagnoses.joins( :week ).order( week_num: :desc ).take.week
      #render previous_week.get_next
    end
  end
end

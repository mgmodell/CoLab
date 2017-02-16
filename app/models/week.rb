class Week < ActiveRecord::Base
  belongs_to :narrative, inverse_of: :weeks
  has_one :behavior, through: :narrative

  has_many :diagnoses, inverse_of: :week

  def percent_complete
    percent_complete = (100 * ( self.week_num.to_f / narrative.weeks.count ) ).to_i
  end
end

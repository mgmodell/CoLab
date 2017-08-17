# frozen_string_literal: true
class Week < ActiveRecord::Base
  translates :text
  belongs_to :narrative, inverse_of: :weeks
  has_one :behavior, through: :narrative

  has_many :diagnoses, inverse_of: :week

  def percent_complete
    percent_complete = (100 * ((week_num - 1).to_f / narrative.weeks.count)).to_i
  end
end

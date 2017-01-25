class Course < ActiveRecord::Base
  belongs_to :school, inverse_of: :courses
  has_many :projects, inverse_of: :course
  has_many :rosters, inverse_of: :course

  validates :timezone, :start_date, :end_date, presence: true
  validate :date_sanity

  before_save :timezone_adjust

  # Validation check code
  def date_sanity
    if start_date > end_date
      errors.add(:start_dow, 'The start date must come before the end date')
    end
    errors
  end

  def timezone_adjust
    if start_date.zone != timezone
      start_date = ActiveSupport::TimeZone.new(timezone).local_to_utc(start_date.beginning_of_day)
      end_date = ActiveSupport::TimeZone.new(timezone).local_to_utc(end_date.end_of_day)
    end
  end
end

class Course < ActiveRecord::Base
  belongs_to :school, inverse_of: :courses
  has_many :projects, inverse_of: :course
  has_many :rosters, inverse_of: :course

  has_many :experiences, inverse_of: :course

  validates :timezone, :start_date, :end_date, presence: true
  validate :date_sanity

  after_validation :timezone_adjust

  # Validation check code
  def date_sanity
    if start_date > end_date
      errors.add(:start_dow, 'The start date must come before the end date')
    end
    errors
  end

  def timezone_adjust
    tz = ActiveSupport::TimeZone.new(timezone)
    if self.start_date_changed?
      revDate = self.start_date.beginning_of_day + tz.utc_offset
      self.start_date = revDate
    end
    if self.end_date_changed?
      revDate = self.end_date.end_of_day + tz.utc_offset
      self.end_date = revDate
    end
  end
end

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
      self.start_date -= tz.utc_offset
    end
    if self.end_date_changed?
      self.end_date -= tz.utc_offset
    end
  end
end

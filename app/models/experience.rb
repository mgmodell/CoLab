class Experience < ActiveRecord::Base
  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience

  validates :name, :end_date, :start_date, presence: true

  validate :date_sanity
  after_validation :timezone_adjust

  scope :still_open, -> { where( 'experiences.end_date >= ? AND experiences.start_date <= ?', DateTime.current, DateTime.current ) }

  def date_sanity
    unless start_date.nil? || end_date.nil?
      if start_date > end_date
        errors.add(:start_date, 'The start date must come before the end date')
      end
      errors
    end
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)
    self.start_date -= course_tz.utc_offset if start_date_changed?
    self.end -= course_tz.utc_offset if end_date_changed?
  end
end

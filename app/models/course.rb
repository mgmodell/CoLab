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
    #unless start_date.nil? || end_date.nil?
            if self.start_date.zone != timezone
              tz = ActiveSupport::TimeZone.new(timezone)
              sd_bod = tz.local_to_utc( self.start_date.beginning_of_day )
              ed_eod = tz.local_to_utc( self.end_date.end_of_day )
              self.start_date = sd_bod
              self.end_date = ed_eod
            end
    #end
  end
end

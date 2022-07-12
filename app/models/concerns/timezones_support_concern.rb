# frozen_string_literal: true

module TimezonesSupportConcern
  extend ActiveSupport::Concern

  included do
    before_validation :timezone_adjust, on: :update
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)

    if start_date.change(hour: 0) <= course.start_date.change(hour: 0)
      self.start_date = course.start_date
    elsif start_date_changed?
      proc_date = course_tz.local(start_date.year, start_date.month, start_date.day)
      self.start_date = proc_date.beginning_of_day
    end

    if end_date.change(hour: 0) >= course.end_date.change(hour: 0)
      self.end_date = course.end_date
    elsif end_date_changed?
      proc_date = course_tz
                  .local(end_date.year, end_date.month, end_date.day, 23, 59)
      self.end_date = proc_date
    end
  end
end

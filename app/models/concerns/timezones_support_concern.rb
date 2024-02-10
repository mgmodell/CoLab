# frozen_string_literal: true

module TimezonesSupportConcern
  extend ActiveSupport::Concern

  included do
    before_validation :timezone_adjust_update, on: :update
    before_validation :timezone_adjust_create, on: :create
  end

  def timezone_adjust_update
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
      tmp_date = course_tz.local(end_date.year, end_date.month, end_date.day)
      self.end_date = tmp_date.end_of_day

    end
  end

  def timezone_adjust_create
    course_tz = ActiveSupport::TimeZone.new(course.timezone)

    if start_date.nil? || start_date.change(hour: 0) <= course.start_date.change(hour: 0)
      self.start_date = course.start_date
    else
      proc_date = course_tz.local(start_date.year, start_date.month, start_date.day)
      self.start_date = proc_date.beginning_of_day
    end

    if end_date.nil? || end_date.change(hour: 0) >= course.end_date.change(hour: 0)
      self.end_date = course.end_date
    else
      tmp_date = course_tz.local(end_date.year, end_date.month, end_date.day)
      self.end_date = tmp_date.end_of_day
    end
  end
end

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
      proc_date = course_tz
                  .local(end_date.year, end_date.month, end_date.day, 23, 59)
      self.end_date = proc_date
    end
  end

  def timezone_adjust_create
    course_tz = ActiveSupport::TimeZone.new(course.timezone)
    # puts "\nName: #{get_type}"
    # puts "1. start: #{start_date} \tend: #{end_date}"

    if start_date.nil? || start_date.change(hour: 0) <= course.start_date.change(hour: 0)
      self.start_date = course.start_date
    elsif start_date_changed?
      proc_date = course_tz.local(start_date.year, start_date.month, start_date.day)
      self.start_date = proc_date.beginning_of_day
    end
    # puts "2. start: #{start_date} \tend: #{end_date}"

    if end_date.nil? || end_date.change(hour: 0) >= course.end_date.change(hour: 0)
      self.end_date = course.end_date
    elsif end_date_changed?
      # puts "year: #{end_date.year}\tmonth: #{end_date.month}\tdate: #{end_date.day}"
      # puts "year: #{end_date.in_time_zone(course_tz).year}\tmonth: #{end_date.in_time_zone(course_tz).month}\tdate: #{end_date.in_time_zone(course_tz).day}"

      tmp_date = end_date.in_time_zone(course_tz)
      proc_date = course_tz
                  .local(tmp_date.year, tmp_date.month, tmp_date.day, 23, 59)
      self.end_date = proc_date
      # puts "proc year: #{proc_date.utc.year}\tmonth: #{proc_date.utc.month}\tdate: #{proc_date.utc.day}"
    end
    # puts "3. start: #{start_date} \tend: #{end_date}"
  end
end

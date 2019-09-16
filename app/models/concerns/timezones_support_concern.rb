module TimezonesSupportConcern
  extend ActiveSupport::Concern

  included do
    before_validation :timezone_adjust
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)

    if start_date.nil? || start_date.change(hour: 0) <= course.start_date.change(hour: 0)
      self.start_date = course.start_date
    elsif start_date_changed?
      proc_date = course_tz.local(start_date.year, start_date.month, start_date.day)
      self.start_date = proc_date.beginning_of_day
    end

    puts "\n\n\n\t********* pre:"
    puts "I'm concerned"
    puts "ED: #{end_date}"

    if end_date.nil? || end_date.change(hour: 0) >= course.end_date.change(hour: 0)
      self.end_date = course.end_date
    elsif end_date_changed?
      puts "found: #{end_date.year}-#{end_date.month}-#{end_date.day}"
      proc_date = course_tz
        .local(end_date.year, end_date.month, end_date.day, 23, 59)
      puts "converted: #{proc_date}"
      self.end_date = proc_date
    end
    puts "ED: #{course_tz.utc_to_local( self.end_date )}"
    puts "\t********* post:\n\n\n"

  end
end

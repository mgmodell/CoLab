module PersonalizationHelper

  def get_theme_code
    @current_user.nil? ? "a" : @current_user.theme.code
  end

  def get_anonymous
    @current_research || @current_user.anonymize?
  end

  def in_tz( date:, tz_str: @current_user.timezone )
    pd = nil
    unless date.nil?
      puts "**********"
      puts "\t\t\tinput #{date}"
      tz = ActiveSupport::TimeZone.new( tz_str )
      pd = tz.local( date.year, date.month, date.day, date.hour, date.min )
      puts "\t\t\toutput #{ pd }"
    end
    pd
  end

end

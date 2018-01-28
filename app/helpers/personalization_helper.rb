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
      puts "********** in tz"
      puts "\t\t\tinput #{date}"
      tz = ActiveSupport::TimeZone.new( tz_str )
      pd = tz.local( date.year, date.month, date.day, date.hour, date.min )
      puts "\t\t\toutput #{ pd }"
    end
    pd
  end

  def convert_to_tz( date:, tz_str: @current_user.timezone )
    pd = nil
    unless date.nil?
      puts "********** convert to tz"
      puts "\t\t\tinput #{date}"
      tz = ActiveSupport::TimeZone.new( tz_str )
      pd = date + tz.utc_offset
      puts "\t\t\toutput #{ pd }"
    end
    pd
  end


end

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
      tz = ActiveSupport::TimeZone.new( tz_str )
      pd = tz.local( date.year, date.month, date.day, date.hour, date.min )
    end
    pd
  end

  def convert_to_tz( date:, tz_str: @current_user.timezone )
    pd = nil
    unless date.nil?
      tz = ActiveSupport::TimeZone.new( tz_str )
      pd = date + tz.utc_offset
    end
    pd
  end


end

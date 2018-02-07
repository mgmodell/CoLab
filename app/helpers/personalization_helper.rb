# frozen_string_literal: true

module PersonalizationHelper
  def get_theme_code
    @current_user.nil? ? 'a' : @current_user.theme.code
  end

  def get_anonymous
    @current_research || @current_user.anonymize?
  end

  def in_tz(date:)
    pd = nil
    unless date.nil?
      tz = ActiveSupport::TimeZone.new(@current_user.timezone)
      pd = tz.parse( date.to_s )
    end
    puts "--- helper\n #{date}\n #{pd}"
    pd
  end

  def to_tz(date:, tz_str:)
    pd = nil
    unless date.nil?
      tz = ActiveSupport::TimeZone.new(tz_str)
      pd = date + tz.utc_offset
    end
    pd
  end
end

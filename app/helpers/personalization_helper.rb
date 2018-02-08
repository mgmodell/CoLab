# frozen_string_literal: true

module PersonalizationHelper
  def get_theme_code
    @current_user.nil? ? 'a' : @current_user.theme.code
  end

  def get_anonymous
    @current_research || @current_user.anonymize?
  end

  def in_tz(date:, tz_str: @current_user.timezone)
    pd = nil
    unless date.nil?
      tz = ActiveSupport::TimeZone.new(tz_str)
      pd = tz.parse(date.to_s)
    end
    pd
  end

  def date_field_in_tz(date:, tz_str:)
    pd = nil
    unless date.nil?
      tz = ActiveSupport::TimeZone.new(tz_str)
      pd = (date + tz.utc_offset).strftime "%F"
    end
    pd
  end
end

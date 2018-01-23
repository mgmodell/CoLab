module PersonalizationHelper

  def get_theme_code
    @current_user.nil? ? "a" : @current_user.theme.code
  end

  def get_anonymous
    @current_research || @current_user.anonymize?
  end

  def in_tz( date:, tz: @current_user.timezone )
    date.in_time_zone( tz )
  end

end

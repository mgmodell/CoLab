# frozen_string_literal: true

class LocalesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_around_action :switch_locale

  def get_resources
    ns = params[:ns]
    lng = params[:lng]

    # Normalize locale: if the requested locale (e.g. "en-US") is not available,
    # fall back to the base language code (e.g. "en"), then to the default locale.
    lng = normalize_locale( lng )

    texts = if 'base' == ns
              I18n.t '.', locale: lng
            else
              I18n.t ns, locale: lng
            end

    render json: texts
  end

  private

  def normalize_locale( lng )
    available = I18n.available_locales.map( &:to_s )
    return lng if available.include?( lng )

    base = lng.split( '-' ).first
    return base if available.include?( base )

    I18n.default_locale.to_s
  end
end

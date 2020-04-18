# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale, if: :user_signed_in?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:
              %i[first_name last_name email password language_id
                 current_password timezone gender_id cip_code_id
                 welcomed theme_id school_id date_of_birth
                 started_school primary_language_id home_state_id
                 impairment_visual impairment_auditory
                 impairment_motor impairment_cognitive
                 impairment_other])
    devise_parameter_sanitizer.permit(:account_update, keys:
              %i[first_name last_name email password language_id
                 current_password timezone gender_id cip_code_id
                 welcomed theme_id school_id researcher date_of_birth
                 started_school primary_language_id home_state_id
                 impairment_visual impairment_auditory
                 impairment_motor impairment_cognitive
                 impairment_other])
  end

  def set_locale
    # TODO: remove this once we are no longer tied to the interface - maybe
    # Time.zone = current_user.timezone if current_user.timezone
    I18n.locale = current_user.language_code || params[:lang] || I18n.default_locale
  end
end

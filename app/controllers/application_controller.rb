# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_locale, if: :user_signed_in?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:
              [:first_name, :last_name, :email, :password, :language_id,
               :current_password, :timezone,  :gender_id, :cip_code_id,
               :welcomed, :theme_id, :school_id, :date_of_birth,
               :started_school, :primary_language_id, :home_state_id])
    devise_parameter_sanitizer.permit(:account_update, keys:
              [:first_name, :last_name, :email, :password, :language_id,
               :current_password, :timezone, :gender_id, :cip_code_id,
               :welcomed, :theme_id, :school_id, :researcher, :date_of_birth,
               :started_school, :primary_language_id, :home_state_id])
  end

  def set_locale
    Time.zone = current_user.timezone if current_user.timezone
    I18n.locale = current_user.language_code || params[:lang] || I18n.default_locale
  end
end

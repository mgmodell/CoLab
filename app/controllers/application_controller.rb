# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale

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
    devise_parameter_sanitizer.permit(:validate, keys:
              %i[id_token])
  end

  def switch_locale(&action)
    locale = if user_signed_in?
               current_user.language_code
             else
               params[:lang] || I18n.default_locale
             end
    I18n.with_locale(locale, &action)
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_time_zone, if: :user_signed_in?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :current_password, :age_range_id, :timezone, :country, :gender_id, :welcomed, :theme_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :password, :current_password, :age_range_id, :timezone, :country, :gender_id, :welcomed, :theme_id])
  end

  def set_time_zone
    Time.zone = current_user.timezone if current_user.timezone
  end
end

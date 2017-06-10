# frozen_string_literal: true
class RegistrationsController < Devise::RegistrationsController
  before_action :set_email, only: [:set_primary_email, :remove_email]

  def set_primary_email
    @current_user.primary_email = @email
    redirect_to edit_user_registration_url, notice: 'Primary email has been set.'
  end

  def add_email
    address = params[:email_address]
    email = Email.create(email: address, user: @current_user)
    logger.debug email.errors.full_messages unless email.errors.empty?
    notice = email.errors.empty? ? 'Email was successfully added.' : 'The email could not be added. It may already be in use. Please contact support.'
    redirect_to edit_user_registration_url, notice: notice
  end

  def remove_email
    @email.destroy
    redirect_to edit_user_registration_url, notice: 'Email was successfully destroyed.'
  end

  def initiate_password_reset
    @current_user.send_reset_password_instructions
    redirect_to root_url, notice: 'A password reset link has been sent to your email address. Please log out and use the link to reset your password.'
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private

  def set_email
    @email = Email.find(params[:email_id])
    redirect_to root_path unless @email.user == @current_user
  end
end

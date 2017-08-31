# frozen_string_literal: true
class RegistrationsController < Devise::RegistrationsController
  before_action :set_email, only: [:set_primary_email, :remove_email]

  def set_primary_email
    @current_user.primary_email = @email
    redirect_to edit_user_registration_path, notice: t('.set_primary')
  end

  def add_email
    address = params[:email_address]
    email = Email.create(email: address, user: @current_user)
    logger.debug email.errors.full_messages unless email.errors.empty?
    notice = email.errors.empty? ?
      t('devise.registrations.email_added') :
      t('devise.registrations.email_not_added')
    redirect_to edit_user_registration_path, notice: notice
  end

  def remove_email
    @email.destroy
    redirect_to edit_user_registration_path, notice: t('.email_destroyed')
  end

  def initiate_password_reset
    @current_user.send_reset_password_instructions
    redirect_to root_url, notice: t('devise.passwords.send_instructions')
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

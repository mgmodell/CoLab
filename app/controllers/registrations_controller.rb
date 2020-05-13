# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :set_email, only: %i[set_primary_email remove_email]

  def set_primary_email
    found = false
    msg = t('devise.registrations.set_primary_fail')
    current_user.emails.each do |email|
      if @email == email
        email.primary = true
        found = true
      else
        email.primary = false
      end
    end
    #make sure
    if found
      current_user.save
      msg = t('devise.registrations.set_primary')
    else
      current_user.emails.reload
    end

    resp = {
      emails: current_user.emails.as_json(
        only: %i[ id email primary ],
        methods: [ 'confirmed?']
      ),
      messages: { main: msg }

    }
    #redirect_to edit_user_registration_path, notice: t('.set_primary')
    respond_to do |format|
      format.json do
        render json: resp
      end
    end
  end

  def add_email
    address = params[:email_address]
    email = Email.create(email: address, user: current_user)

    logger.debug email.errors.full_messages unless email.errors.empty?
    msg = email.errors.empty? ?
      t('devise.registrations.email_added') :
      t('devise.registrations.email_not_added')
    # redirect_to edit_user_registration_path, notice: notice

    resp = {
      emails: current_user.emails.as_json(
        only: %i[ id email primary ],
        methods: [ 'confirmed?']
      ),
      messages: { main: msg }

    }
    respond_to do |format|
      format.json do
        render json: resp
      end
    end
  end

  def remove_email
    @email.destroy
    resp = {
      emails: current_user.emails.as_json(
        only: %i[ id email primary ],
        methods: [ 'confirmed?']
      ),
      messages: { main: t('devise.registrations.email_destroyed')}

    }
    #redirect_to edit_user_registration_path, notice: t('devise.registrations.email_destroyed')
    respond_to do |format|
      format.json do
        render json: resp
      end
    end
  end

  def initiate_password_reset
    current_user.send_reset_password_instructions
    redirect_to root_url, notice: t('devise.passwords.send_instructions')
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private

  def set_email
    @email = Email.find(params[:email_id])
    redirect_to root_path unless @email.user == current_user
  end
end

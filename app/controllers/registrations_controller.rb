# frozen_string_literal: true

class RegistrationsController < DeviseTokenAuth::RegistrationsController
  before_action :set_email, only: %i[set_primary_email remove_email]
  skip_before_action :authenticate_user!, only: %i[ create initiate_password_reset ]

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
    # make sure
    if found
      current_user.save
      msg = t('devise.registrations.set_primary')
    else
      current_user.emails.reload
    end

    resp = {
      emails: current_user.emails.as_json(
        only: %i[id email primary],
        methods: ['confirmed?']
      ),
      messages: { main: msg }

    }
    # redirect_to edit_user_registration_path, notice: t('.set_primary')
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
    msg = if email.errors.empty?
            t('devise.registrations.email_added')
          else
            t('devise.registrations.email_not_added')
          end
    # redirect_to edit_user_registration_path, notice: notice

    resp = {
      emails: current_user.emails.as_json(
        only: %i[id email primary],
        methods: ['confirmed?']
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
        only: %i[id email primary],
        methods: ['confirmed?']
      ),
      messages: { main: t('devise.registrations.email_destroyed') }

    }
    # redirect_to edit_user_registration_path, notice: t('devise.registrations.email_destroyed')
    respond_to do |format|
      format.json do
        render json: resp
      end
    end
  end

  # Initiate self-registration without a password
  # pulled from: https://stackoverflow.com/questions/31535526/email-only-signup-using-devise-rails
  def create
    build_resource
    @resource.password = SecureRandom.hex( 10 ) #sets the password
    @resource.save

    resp = {
      message: 'registrations.signup_failed'
    }
    yield @resource if block_given?
    if @resource.persisted?
      @resource.send_reset_password_instructions #send them instructions how to reset their password

      if @resource.active_for_authentication?
        sign_up( @resource_name, @resource )
      else
        expire_data_after_sign_in!
        resp[:message] = 'registrations.signed_up_but_inactive'
      end
    else
      resp[:message] = @resource.errors.full_messages
      clean_up_passwords resource
      set_minimum_password_length
    end

    respond_to do |format|
      format.json do
        render json: resp
      end
    end

  end

  def initiate_password_reset

    resp = {
      message: current_user.present? ? 'passwords.send_instructions' : 'passwords.send_paranoid_instructions'
    }

    reset_user = if current_user.present? 
      current_user 
    else
      User.find_by_email params[:email]
    end

    reset_user.send_reset_password_instructions if reset_user.present?

    respond_to do |format|
      format.json do
        render json: resp
      end
    end
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

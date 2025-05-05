# frozen_string_literal: true

class RegistrationsController < DeviseTokenAuth::RegistrationsController
  before_action :set_email, only: %i[set_primary_email remove_email]
  skip_before_action :authenticate_user!,
                     only: %i[create initiate_password_reset confirm password_change]

  def set_primary_email
    found = false
    msg = t( 'devise.registrations.set_primary_fail' )
    current_user.emails.each do | email |
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
      msg = t( 'devise.registrations.set_primary' )
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
    respond_to do | format |
      format.json do
        render json: resp
      end
    end
  end

  def add_email
    address = params[:email_address]
    email = Email.create( email: address, user: current_user )

    logger.debug email.errors.full_messages unless email.errors.empty?
    msg = if email.errors.empty?
            t( 'devise.registrations.email_added' )
          else
            t( 'devise.registrations.email_not_added' )
          end
    # redirect_to edit_user_registration_path, notice: notice

    resp = {
      emails: current_user.emails.as_json(
        only: %i[id email primary],
        methods: ['confirmed?']
      ),
      messages: { main: msg }

    }
    respond_to do | format |
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
      messages: { main: t( 'devise.registrations.email_destroyed' ) }

    }
    # redirect_to edit_user_registration_path, notice: t('devise.registrations.email_destroyed')
    respond_to do | format |
      format.json do
        render json: resp
      end
    end
  end

  # Initiate self-registration without a password
  # pulled from: https://stackoverflow.com/questions/31535526/email-only-signup-using-devise-rails
  def create
    resp = {
      error: true,
      message: 'registrations.signup_failed'
    }
    user_email = params[:email]
    if EmailAddress.valid? user_email
      user = User.joins( :emails ).find_by( emails: { email: user_email } )
      if user.nil?
        passwd = SecureRandom.alphanumeric( 10 )
        user = User.create(
          email: user_email,
          first_name: params[:first_name],
          last_name: params[:last_name],
          admin: false,
          password: passwd
        )
        if user.persisted?
          user.send_confirmation_instructions
          resp[:error] = false
          resp[:message] = 'registrations.signed_up_but_inactive'
        end
      end
    end

    respond_to do | format |
      format.json do
        render json: resp
      end
    end
  end

  def confirm
    token = params[:confirmation_token]

    # Because I'm using devise_multi-email, this will return
    # an email object
    email = User.confirm_by_token token
    token = email.user.send_reset_password_instructions

    redirect_to password_edit_path reset_password_token: token
  end

  def initiate_password_reset
    resp = {
      message: current_user.present? ? 'passwords.send_instructions' : 'passwords.send_paranoid_instructions'
    }

    reset_user = current_user.presence || User.find_by( email: params[:email] )

    reset_user.send_reset_password_instructions if reset_user.present?

    respond_to do | format |
      format.json do
        render json: resp
      end
    end
  end

  def password_change
    resp = {
      error: true,
      message: 'passwords.no_token'
    }
    token = params[:reset_password_token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    unless token.empty? || password.empty? || password_confirmation.empty? || password != password_confirmation
      user = User.reset_password_by_token(
        {
          reset_password_token: token,
          password:,
          password_confirmation:
        }
      )
      sign_in( user )
      tokens = user.create_new_auth_token
      user.save
      set_headers( tokens )
      resp[:error] = false
      resp[:message] = 'passwords.updated'
    end
    respond_to do | format |
      format.json do
        render json: resp
      end
    end
  end

  protected

  def update_resource( resource, params )
    resource.update_without_password( params )
  end

  private

  def set_email
    @email = current_user.emails.find( params[:email_id] )
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end

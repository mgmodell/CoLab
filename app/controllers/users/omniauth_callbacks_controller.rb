# frozen_string_literal: true

# This class supports OmniAuth authentication verification.
# It is specific to Google Authentication.
class Users::OmniauthCallbacksController < ApplicationController

  skip_before_action :authenticate_user!, only: %i[validate]

  def validate
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params["id_token"]}"
    response = Faraday.get( url )

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth( JSON.parse( response.body ) )
    message = 'no login yet'

    if @user.persisted?
      message = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      tokens = @user.create_new_auth_token
      @user.save
      set_headers( tokens )
      # sign_in_and_redirect @user, event: :authentication
    else
      logger.debug @user.errors.full_messages unless @user.errors.empty?
      session['devise.google_data'] = request.env['omniauth.auth']
      message = I18n.t 'devise.omniauth_callbacks.failure', reason: 'not sure'
      # Clean up the error handling

      # redirect_to new_user_registration_url
    end

    respond_to do |format|
      format.json do
        render json: { message: message }
      end
    end
  end

  def failure
    redirect_to root_path
  end

  private

  def set_headers(tokens)
    headers['access-token'] = (tokens['access-token']).to_s
    headers['client'] =  (tokens['client']).to_s
    headers['expiry'] =  (tokens['expiry']).to_s
    headers['uid'] =@user.uid
    headers['token-type'] = (tokens['token-type']).to_s
  end
end

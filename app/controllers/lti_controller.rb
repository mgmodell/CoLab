# frozen_string_literal: true

class LtiController < ApplicationController
  skip_before_action :authenticate_user!

  def register
    puts "\n\n\n\tLTI Registration"
    puts params.inspect
    puts "***************"

    response = {
      client_name: 'CoLab.online',
      initiate_login_uri: 'https://colab.online/users/sign_in',
      redirect_uris: ['https://colab.online/users/auth/lti/callback'],
      jwks_uri: 'https://colab.online/.well-known/jwks.json',
      scopes: ['openid', 'profile', 'email', 'offline_access'],
    }

    respond_to do |format|
      format.json do
        render json: response
      end
    end
  end
end

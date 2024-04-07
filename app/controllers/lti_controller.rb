# frozen_string_literal: true
require 'socket'

class LtiController < ApplicationController
  skip_before_action :authenticate_user!

  def register
    puts "\n\n\n\tLTI Registration"
    puts params.inspect
    puts Socket.gethostname
    puts request.host_with_port
    puts request.port
    puts Rails.configuration.machine_name
    puts "***************"

    response = {
      issuer: "https://#{request.host_with_port}",
      client_name: 'CoLab.online',
      initiate_login_uri: "https://#{request.host_with_port}/users/sign_in",
      redirect_uris: ["https://#{request.host_with_port}/users/auth/lti/callback"],
      jwks_uri: "https://#{request.host_with_port}/.well-known/jwks.json",
      scopes_supported: %w[openid profile email offline_access],
    }

    render json: response

    # respond_to do |format|
    #   format.json do
    #     render json: response
    #   end
    # end
  end
end

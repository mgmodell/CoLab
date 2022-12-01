# frozen_string_literal: true

module Users
  class SessionsController < DeviseTokenAuth::SessionsController
    # include DeviseTokenAuth::Concerns::UserOmniauthCallbacks
    skip_before_action :authenticate_user!, only: [:create]
  end
end

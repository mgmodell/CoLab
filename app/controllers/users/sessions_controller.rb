# frozen_string_literal: true

class Users::SessionsController < DeviseTokenAuth::SessionsController
  # include DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  skip_before_action :authenticate_user!, only: [:create]

  def create
    super
  end

end

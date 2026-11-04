# frozen_string_literal: true

# Lets the native iOS / Android apps register (or remove) the current user's
# device token so that push notifications can be delivered to it.
class PushDevicesController < ApplicationController
  PLATFORMS = %w[apple google].freeze

  def create
    platform = params[:platform].to_s
    token = params[:token].to_s
    unless PLATFORMS.include?( platform ) && token.present?
      return render json: { error: 'invalid platform or token' }, status: :unprocessable_content
    end

    device = current_user.push_devices.find_or_initialize_by( platform: platform, token: token )
    device.name = params[:name].to_s.presence
    if device.save
      render json: { id: device.id }, status: :ok
    else
      render json: { error: device.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    current_user.push_devices.where( token: params[:token].to_s ).destroy_all
    head :no_content
  end
end

# frozen_string_literal: true

# Delivers real-time in-app notifications to individual logged-in users,
# complementing the email notifications already sent by AdministrativeMailer.
# Each user subscribes with their own id so broadcasts are private.
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from self.class.channel_name( current_user.id )
  end

  def unsubscribed
    stop_all_streams
  end

  # Broadcast a single notification to a specific user.
  # +user_id+    – integer id of the recipient
  # +message+    – human-readable notification text
  # +priority+   – severity string matching the client-side Priorities enum
  #                ('info', 'warning', 'error')
  def self.broadcast_to_user( user_id:, message:, priority: 'info' )
    ActionCable.server.broadcast(
      channel_name( user_id ),
      { message:, priority: }
    )
  end

  def self.channel_name( user_id )
    "notifications_user_#{user_id}"
  end
end

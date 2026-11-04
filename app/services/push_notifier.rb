# frozen_string_literal: true

# Sends native (iOS / Android) push notifications to a user's registered
# devices via the action_push_native gem. Silently does nothing when the user
# has no registered devices or when push is not configured, so it is always
# safe to call alongside email / in-app notifications.
class PushNotifier
  def self.notify( user, title:, body: )
    return unless defined?( ActionPushNative )

    devices = user.push_devices.to_a
    return if devices.empty?

    ApplicationPushNotification.new( title: title, body: body.to_s.strip )
                               .deliver_later_to( devices )
  rescue StandardError => e
    Rails.logger.error "Push notification failed for user #{user&.id}: #{e.message}"
  end
end

# frozen_string_literal: true

# Stores the short-lived OIDC state/nonce pair created during an LTI 1.3
# login initiation (/lti/login) and consumed at launch (/lti/launch).
#
# State is stored here rather than in the browser session because the LTI
# OIDC flow involves cross-site form POSTs (Moodle → CoLab) and session
# cookies may not be sent cross-site regardless of SameSite settings.
#
# Records are single-use: the matching record is destroyed as soon as the
# launch is validated.  Expired records are cleaned up on write.
class LtiNonce < ApplicationRecord
  EXPIRY = 10.minutes

  validates :state, :nonce, presence: true
  validates :state, uniqueness: true

  # Create a new state/nonce pair that expires in EXPIRY.
  # Also purges any already-expired records to keep the table small.
  def self.generate
    purge_expired
    create!(
      state: SecureRandom.urlsafe_base64(32),
      nonce: SecureRandom.urlsafe_base64(32),
      expires_at: EXPIRY.from_now
    )
  end

  def expired?
    expires_at <= Time.current
  end

  def self.purge_expired
    where(expires_at: ..Time.current).delete_all
  end
end

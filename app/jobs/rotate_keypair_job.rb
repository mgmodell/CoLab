# frozen_string_literal: true

class RotateKeypairJob < ApplicationJob
  queue_as :default

  # keypairs gem default lifetime is 90 days; rotate 30 days before expiry,
  # i.e. schedule the next rotation 60 days after creating a new key.
  ROTATION_INTERVAL = 60.days

  def perform
    Keypair.create!
    self.class.set(wait: ROTATION_INTERVAL).perform_later
  end
end

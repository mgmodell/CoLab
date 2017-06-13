# frozen_string_literal: true
class Email < ActiveRecord::Base
  belongs_to :user, inverse_of: :emails

  validate :check_confirmed

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  protected
  def check_confirmed
    if primary && !confirmed?
      errors.add(:primary, "An email must be confirmed before you can make it primary." )
    end
  end
end

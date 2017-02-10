class Email < ActiveRecord::Base
  belongs_to :user, inverse_of: :emails

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end

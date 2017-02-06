class ReminderMailer < ActionMailer::Base
  default from: 'support@peerassess.info'

  def remind(user)
    @user = user
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: 'CoLab Assessment reminder email')
  end
end

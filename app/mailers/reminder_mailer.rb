class ReminderMailer < ActionMailer::Base
  default from: 'support@CoLab.online'

  def remind(user)
    @user = user
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: 'CoLab Assessment reminder email',
         tag: 'reminder',
         track_opens: 'true')
  end
end

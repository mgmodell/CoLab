class AdministrativeMailer < ActionMailer::Base
  default from: 'support@CoLab.online'

  def remind(user)
    @user = user
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: 'CoLab Assessment reminder email',
         tag: 'reminder',
         track_opens: 'true')
  end

  def summary_report(user, completion_hash)
    @user = user
    @completion_report = completion_hash
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: 'CoLab Assessment status email',
         tag: 'reminder',
         track_opens: 'true')
  end

end

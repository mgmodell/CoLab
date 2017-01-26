namespace :cron do
  
  desc "Set up the infrastructure for any currently open assessments"
  task :populate_assessments => :environment do
    Assessment.set_up_assessments
  end

  desc "Send out email reminders to students with open items"
  task :send_emails => :environment do
    Assessment.send_reminder_emails
  end

end

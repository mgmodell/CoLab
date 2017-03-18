# frozen_string_literal: true
namespace :admin do
  desc 'Set up the infrastructure for currently open assessments'
  task populate_assessments: :environment do
    Assessment.set_up_assessments
  end

  desc 'Set up infrastructure and send reminders and summaries'
  task remind: :environment do
    Assessment.set_up_assessments
    AdministrativeMailer.send_reminder_emails
    Assessment.inform_instructors
    Experience.inform_instructors
  end
end

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
    AdministrativeMailer.inform_instructors
  end

  desc 'Promote a user to an admin'
  task :set_admin, [:admin] => [:environment] do |_t, args|
    if args[:admin] != 'true' && args[:admin] != 'false'
      puts '  This task sets up administrators in CoLab test environments'
      puts '   Usage:   rake admin:set_admin[<new admin value>,<list of emails>]'
      puts "   Example: rake admin:set_admin['true','john_smith@gmail.com']"
      puts "   Example: rake admin:set_admin['false','john_smith@gmail.com']"
    else
      admin_value = args[:admin] == 'true'
      args.extras.each do |email|
        user = User.joins(:emails).where(emails: { email: email }).take
        if user.nil?
          puts "User with email <#{email}> not found"
        else
          user.admin = admin_value
          user.save
          if !user.errors.nil? && user.errors.count > 0
            puts user.errors.full_messages
          else
            puts "#{user.name} <#{email}> is admin? #{admin_value}"
          end
        end
      end
    end
  end
end

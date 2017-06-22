# frozen_string_literal: true
require 'forgery'
namespace :testing do

  desc 'Set up some simple, current objects for testing'
  task :examples, [:tester] => [:environment] do |_t, args|
    if args[:tester].empty?
      puts '  This task sets up example objects for testers in CoLab test environments'
      puts '   Usage:   rake testing:examples[<user email>]'
      puts '   Example: rake testing:examples[\'john_smith@gmail.com\']'
    else
      user = User.joins(:emails).where( emails: {email: args[:tester]} ).take
      course = Course.new
      course.school = School.find 1
      course.name = "Advanced #{Forgery::Name.industry}"
      course.timezone = user.timezone
      course.start_date{ 2.weeks.ago }
      course.end_date{ 2.weeks.from_now }
      course.save
      
      course.add_user_by_email user.email

      #Create an experience for the user
      experience = Experience.new
      experience.name = "#{Forgery::Name.industry} Group Simulation"
      experience.start_date = 1.weeks.ago
      experience.end_date = DateTime.tomorrow
      experience.active = true
      experience.save

      #Create Project with the user in a group

      #Create BingoGame 

      #Create BingoGame with a user group

    end
  end

  desc 'Promote a user to an admin'
  task :set_admin, [:admin] => [:environment] do |_t, args|
    if args[:admin] != 'true' && args[:admin] != 'false'
      puts '  This task sets up administrators in CoLab test environments'
      puts '   Usage:   rake testing:set_admin[<new admin value>,<list of emails>]'
      puts "   Example: rake testing:set_admin['true','john_smith@gmail.com']"
      puts "   Example: rake testing:set_admin['false','john_smith@gmail.com']"
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

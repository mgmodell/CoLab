# frozen_string_literal: true

namespace :testing do
  desc 'Initialise the Testing DB'
  task :db_init => [:environment] do |_t, args|
    sql = File.read('db/test_db.sql')
    statements = sql.split(/;$/)
    statements.pop # remote empty line
    ActiveRecord::Base.transaction do
      statements.each do |statement|
        ActiveRecord::Base.connection.execute(statement)
      end
    end
    Rake::Task["db:environment:set"].invoke
  end

  desc 'Set up some simple, current objects for testing'
  task :examples, [:tester] => [:environment] do |_t, args|
    require 'forgery'
    if args[:tester].empty?
      puts '  This task sets up example objects for testers in CoLab test environments'
      puts '   Usage:   rake testing:examples[<user email>]'
      puts '   Example: rake testing:examples[\'john_smith@gmail.com\']'
    else
      user = User.joins(:emails).where(emails: { email: args[:tester] }).take
      if user.nil?
        puts "User with email <#{email}> not found"
      else

        course = Course.new
        course.school = School.find 1
        course.name = "Advanced #{Forgery::Name.industry}"
        course.number = "TEST-#{rand(103..550)}"
        course.timezone = user.timezone
        course.start_date = 2.months.ago
        course.end_date = 2.months.from_now
        course.save
        puts course.errors.empty? ?
            "New course: #{course.name}" :
            course.errors.full_messages

        course.add_user_by_email user.email

        # Create an experience for the user
        experience = Experience.new
        experience.name = "#{Forgery::Name.industry} Group Simulation"
        experience.start_date = 1.weeks.ago
        experience.end_date = DateTime.tomorrow
        experience.active = true
        experience.course = course
        experience.save
        puts experience.errors.empty? ?
            "New experience: #{experience.name}" :
            experience.errors.full_messages

        # Create Project with the user in a group
        project = Project.new
        project.name = "#{Forgery::Name.job_title} project"
        project.start_date = 1.months.ago
        project.end_date = 1.months.from_now
        project.start_dow = Date.yesterday.wday
        project.end_dow = Date.tomorrow.wday
        project.course = course
        project.factor_pack = FactorPack.find 1
        project.save
        puts project.errors.empty? ?
            "New project: #{project.name}" :
            project.errors.full_messages

        # Create a group
        group = Group.new
        group.name = Forgery::Basic.text
        group.project = project
        group.users << user
        3.times do
          u = User.new
          u.first_name = Forgery::Name.first_name
          u.last_name = Forgery::Name.last_name
          u.password = 'password'
          u.password_confirmation = 'password'
          u.email = Forgery::Internet.email_address
          u.timezone = 'UTC'
          u.save
          puts u.errors.empty? ?
              "New user: #{u.informal_name false}" :
              u.errors.full_messages
          course.add_user_by_email u.email
          group.users << u
        end
        group.save
        puts group.errors.empty? ?
            "New group: #{group.name}" :
            group.errors.full_messages

        project.active = true
        project.save
        puts project.errors.empty? ?
            'Projct activated' :
            project.errors.full_messages

        # Create BingoGame
        bingo = BingoGame.new
        bingo.topic = Forgery::Name.company_name
        bingo.description = Forgery::LoremIpsum.text
        bingo.course = course
        bingo.start_date = 1.month.ago
        bingo.end_date = 4.days.from_now
        bingo.lead_time = 2
        bingo.individual_count = 10
        bingo.group_option = false
        bingo.active = true
        bingo.save
        puts bingo.errors.empty? ?
            "New solo bingo: #{bingo.topic}" :
            bingo.full_messages

        # Create BingoGame with a user group
        bingo = BingoGame.new
        bingo.topic = Forgery::Name.company_name
        bingo.description = Forgery::LoremIpsum.text
        bingo.course = course
        bingo.start_date = 1.month.ago
        bingo.end_date = 4.days.from_now
        bingo.lead_time = 2
        bingo.individual_count = 10
        bingo.group_option = true
        bingo.group_discount = 35
        bingo.project = project
        bingo.active = true
        bingo.save
        puts bingo.errors.empty? ?
            "New solo bingo: #{bingo.topic}" :
            bingo.full_messages
      end
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
          user = User.new(
            first_name: 'f_name',
            last_name: 'l_name',
            password: 'password',
            password_confirmation: 'password',
            email: email,
            timezone: 'UTC',
            school: School.find( 1 ),
            theme_id: 1
          )
          # puts "User with email <#{email}> not found"
        end
        #else
          user.admin = admin_value
          user.skip_confirmation!
          user.save
          if !user.errors.nil? && user.errors.count > 0
            puts user.errors.full_messages
          else
            puts "#{user.name(false)} <#{email}> is admin? #{admin_value}"
          end
        #end
      end
    end
  end

  desc 'Run and report on our tests in parallel'
  task :parallel_rpt do
    unless Rails.env.production?
      require 'report_builder'
      options = {
        input_path: 'cucumber/',
        report_path: 'test_results',
        report_title: 'CoLab BDD Test Results',
        report_types: [:json, :html],
        voice_commands: true
       }
      ReportBuilder.build_report options
    end
  end
end

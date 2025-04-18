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
    Rake::Task["db:environment:set"].execute
  end

  desc 'Set up some simple, current objects for testing'
  task :examples, [:tester] => [:environment] do |_t, args|
    # require 'faker'
    if args[:tester].nil? || args[:tester].empty?
      puts '  This task sets up example objects for testers in CoLab test environments'
      puts '   Usage:   rake testing:examples[<user email>]'
      puts '   Example: rake testing:examples[john_smith@gmail.com]'
    else
      email = args[:tester]
      user = User.joins(:emails).where(emails: { email: email }).take
      if user.nil?
        puts "User with email <#{email}> not found"
      else
        ActiveRecord::Base.transaction do

          course = Course.new
          course.school = School.find 1
          course.name = "Advanced #{Faker::IndustrySegments.industry}"
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
          experience.name = "#{Faker::IndustrySegments.industry} Group Simulation"
          experience.start_date = 1.weeks.ago
          experience.end_date = 1.weeks.from_now
          experience.active = true
          experience.course = course
          experience.save
          puts experience.errors.empty? ?
              "New experience: #{experience.name}" :
              experience.errors.full_messages

          # Create Project with the user in a group
          project = Project.new
          project.name = "#{Faker::Job.title} project"
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
          group.name = Faker::Team.name
          group.project = project
          group.users << user
          3.times do
            u = User.new
            u.first_name = Faker::Name.first_name
            u.last_name = Faker::Name.last_name
            u.password = 'password'
            u.password_confirmation = 'password'
            u.email = Faker::Internet.email
            u.timezone = 'UTC'
            u.save
            puts u.errors.empty? ?
                "New user: #{u.informal_name false}" :
                u.errors.full_messages
            course.add_user_by_email u.email
            roster = u.rosters.new(
              course: course
            )
            roster.enrolled_student!
            # u.rosters[0].enrolled_student!
            u.save

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
          bingo.topic = Faker::Company.name
          bingo.description = Faker::Lorem.paragraph
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
          bingo.topic = Faker::Company.name
          bingo.description = Faker::Lorem.paragraph
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
          #Create a rubric
          rubric = user.rubrics.new(
            name: Faker::JapaneseMedia::StudioGhibli.movie,
            description: Faker::GreekPhilosophers.quote,
            school: user.school,
            published: true

          )
          rubric.criteria.new(
            description: Faker::Company.industry,
            sequence: 1,
            l1_description: Faker::Company.bs,
            l2_description: Faker::Company.bs,
            l3_description: Faker::Company.bs,
            l4_description: Faker::Company.bs,
            l5_description: Faker::Company.bs
          )
          rubric.criteria.new(
            description: Faker::Company.industry,
            sequence: 2,
            l1_description: Faker::Company.bs,
            l2_description: Faker::Company.bs
          )
          rubric.save
          puts rubric.errors.empty? ?
              "New rubric: #{rubric.name}" :
              rubric.full_messages

          #Create an assignment that uses the rubric
          assignment = course.assignments.new(
            name: Faker::Books::CultureSeries.culture_ship,
            description: Faker::Quote.yoda,
            passing: 65,
            start_date: 4.months.ago,
            end_date: 2.months.from_now,
            active: true,
            rubric: rubric
          )
          assignment.save
          puts assignment.errors.empty? ?
              "New assignment: #{assignment.name}" :
              assignment.errors.full_messages
          # Create a course with email as instructor
          course = Course.new
          course.school = School.find 1
          course.name = "Advanced #{Faker::IndustrySegments.industry}"
          course.number = "TEST-#{rand(103..550)}"
          course.timezone = user.timezone
          course.start_date = 2.months.ago
          course.end_date = 2.months.from_now
          course.save
          puts course.errors.empty? ?
              "New course: #{course.name}" :
              course.errors.full_messages

          # Create Project with the user in a group
          project = Project.new
          project.name = "#{Faker::Job.title} project"
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
          group.name = Faker::Team.name
          group.project = project
          group.users << user
          3.times do
            u = User.new
            u.first_name = Faker::Name.first_name
            u.last_name = Faker::Name.last_name
            u.password = 'password'
            u.password_confirmation = 'password'
            u.email = Faker::Internet.email
            u.timezone = 'UTC'
            u.save
            puts u.errors.empty? ?
                "New user: #{u.informal_name false}" :
                u.errors.full_messages
            course.add_user_by_email u.email
            roster = u.rosters.new(
              course: course
            )
            roster.enrolled_student!
            # u.rosters[0].enrolled_student!
            u.save

            group.users << u
          end
          group.save
          puts group.errors.empty? ?
              "New group: #{group.name}" :
              group.errors.full_messages

          course.add_instructors_by_email user.email
          #Create an assignment that uses the rubric
          assignment = course.assignments.new(
            name: Faker::Books::CultureSeries.culture_ship,
            description: Faker::Quote.yoda,
            passing: 65,
            start_date: 4.months.ago,
            end_date: 2.months.from_now,
            active: true,
            rubric: rubric
          )
          assignment.save
          puts assignment.errors.empty? ?
              "New assignment: #{assignment.name}" :
              assignment.errors.full_messages

          submission = assignment.submissions.new(
            sub_text: Faker::Quote.yoda,
            submitted: Date.yesterday,
            user: group.users.sample
          )
          submission.save
          puts submission.errors.empty? ?
              "New submission: #{submission.id}" :
              submission.errors.full_messages
        end
      end
    end
  end

  desc 'Set email and password for user 1'
  task :haccess, [:email] => [:environment] do | t, args |
    if args[:email].blank?
      puts '  This task sets up the initial admin user in CoLab dev environments'
      puts '  It will set the password to \'password\''
      puts '   Usage:   rake testing:haccess[<email>]'
    else

      puts 'running'
      if Rails.env.development?
        user = User.new(
          email: args[:email],
          admin: true,
          password: 'password',
          password_confirmation: 'password',
          welcomed: true,
          school_id: 1
        )
        user.confirm
        user.save
      else
        puts 'This only works in development'
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
            school: School.find( 1 )
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

  desc 'Anonymize the current db contents'
  task :anon_db_init => [:environment] do |_t, args|

    2.times do
      Installment.transaction do
        Installment.find_each do |installment|
          installment.comments = installment.anon_comments
          installment.anon_comments = ''
          installment.save
        end

        School.find_each do |school|
          school.name = school.anon_name
          school.anon_name = "#{Faker::Color.color_name} #{Faker::Educator.university}" unless school.anon_name?
          school.save
        end


        User.find_each do |user|
          user.first_name = user.anon_first_name
          user.last_name = user.anon_last_name
          Email.transaction do
            user.emails.each do |email|
              email.email =
                "#{user.anon_first_name}_#{user.anon_last_name}_#{user.id}@#{Faker::Internet.domain_name( subdomain:true, domain: 'example' )}"
              email.save!
              email.confirm
            end
          end
          user.anon_first_name = Faker::Name.first_name unless user.anon_first_name?
          user.anon_last_name = Faker::Name.last_name unless user.anon_last_name?
          user.researcher = false unless user.researcher?

          if user.provider == 'email'
            user.uid = user.email
          end
          user.save!
        end

        Group.find_each do |group|
          group.name = group.anon_name
          group.anon_name = "#{rand < rand ? Faker::Nation.language : Faker::Nation.nationality} #{Faker::Company.name}s" unless group.anon_name?
          group.save
        end

        BingoGame.find_each do |bingo_game|
          if !bingo_game.anon_topic? || (bingo_game.anon_topic.starts_with? 'Lorem')
            trans = ['basics for a', 'for an expert', 'in the news with a novice', 'and Food Pyramids - for the']
            bingo_game.topic = bingo_game.anon_topic
            bingo_game.anon_topic = "#{Faker::Company.catch_phrase} #{trans.sample} #{Faker::Job.title}"
            bingo_game.save
          end
        end

        Experience.find_each do |experience|
          experience.name = experience.anon_name
          experience.anon_name = "#{Faker::Company.industry} #{Faker::Company.suffix}" unless experience.anon_name?
          experience.save
        end

        locations = [
          Faker::Games::Pokemon,
          Faker::Games::Touhou,
          Faker::Games::Overwatch,
          Faker::Movies::HowToTrainYourDragon,
          Faker::Fantasy::Tolkien
        ]
        Project.find_each do |project|
          project.name = project.anon_name
          project.anon_name = "#{locations.sample.location} #{Faker::Job.field}" unless project.anon_name?
          project.save
        end


        depts = %w[BUS MED ENG RTG MSM LEH EDP
                   GEO IST MAT YOW GFB RSV CSV MBV]
        levels = %w[Beginning Intermediate Advanced]
        Course.find_each do |course|
          course.name = course.anon_name
          course.number = course.anon_number
          course.anon_name = "#{levels.sample} #{Faker::Company.industry}" unless course.anon_name?
          course.anon_number = "#{depts.sample}-#{rand(100..700)}" unless course.anon_number?
          course.save
        end

        Assignment.find_each do |assignment|
          assignment.anon_name = "#{Faker::Company.profession} #{Faker::Company.industry}"
          assignment.anon_description = "#{Faker::Lorem.sentence(
            word_count: 8,
            supplemental: true,
            random_words_to_add: 9
          )}"
        end
      end
    end
    ActiveRecord::Base.connection.execute("TRUNCATE ahoy_messages" )
  end

end

# frozen_string_literal: true

require 'digest'

namespace :testing do
  desc 'Initialise the Testing DB'
  task db_init: [:environment] do | _t, _args |
    sql = File.read( 'db/test_db.sql' )
    statements = sql.split( /;$/ )
    statements.pop # remote empty line
    ActiveRecord::Base.transaction do
      statements.each do | statement |
        ActiveRecord::Base.connection.execute( statement )
      end
    end
    Rake::Task['db:environment:set'].execute
  end

  desc 'Set up some simple, current objects for testing'
  task :examples, [:tester] => [:environment] do | _t, args |
    # require 'faker'
    if args[:tester].nil? || args[:tester].blank?
      puts '  This task sets up example objects for testers in CoLab test environments'
      puts '   Usage:   rake testing:examples[<user email>]'
      puts '   Example: rake testing:examples[john_smith@gmail.com]'
    else
      email = args[:tester]
      user = User.joins( :emails ).find_by( emails: { email: email } )
      if user.nil?
        puts "User with email <#{email}> not found"
      else
        ActiveRecord::Base.transaction do
          course = Course.new
          course.school = School.find 1
          course.name = "Advanced #{Faker::IndustrySegments.industry}"
          course.number = "TEST-#{rand( 103..550 )}"
          course.timezone = user.timezone
          course.start_date = 2.months.ago
          course.end_date = 2.months.from_now
          course.save
          puts course.errors.empty? ? "New course: #{course.name}" : course.errors.full_messages

          course.add_user_by_email user.email

          # Create an experience for the user
          experience = Experience.new
          experience.name = "#{Faker::IndustrySegments.industry} Group Simulation"
          experience.start_date = 1.week.ago
          experience.end_date = 1.week.from_now
          experience.active = true
          experience.course = course
          experience.save
          puts experience.errors.empty? ? "New experience: #{experience.name}" : experience.errors.full_messages

          # Create Project with the user in a group
          project = Project.new
          project.name = "#{Faker::Job.title} project"
          project.start_date = 1.month.ago
          project.end_date = 1.month.from_now
          project.start_dow = Date.yesterday.wday
          project.end_dow = Date.tomorrow.wday
          project.course = course
          project.factor_pack = FactorPack.find 1
          project.save
          puts project.errors.empty? ? "New project: #{project.name}" : project.errors.full_messages

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
            puts u.errors.empty? ? "New user: #{u.informal_name false}" : u.errors.full_messages
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
          puts group.errors.empty? ? "New group: #{group.name}" : group.errors.full_messages

          project.active = true
          project.save
          puts project.errors.empty? ? 'Projct activated' : project.errors.full_messages

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
          puts bingo.errors.empty? ? "New solo bingo: #{bingo.topic}" : bingo.full_messages

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
          puts bingo.errors.empty? ? "New solo bingo: #{bingo.topic}" : bingo.full_messages
          # Create a rubric
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
          puts rubric.errors.empty? ? "New rubric: #{rubric.name}" : rubric.full_messages

          # Create an assignment that uses the rubric
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
          puts assignment.errors.empty? ? "New assignment: #{assignment.name}" : assignment.errors.full_messages
          # Create a course with email as instructor
          course = Course.new
          course.school = School.find 1
          course.name = "Advanced #{Faker::IndustrySegments.industry}"
          course.number = "TEST-#{rand( 103..550 )}"
          course.timezone = user.timezone
          course.start_date = 2.months.ago
          course.end_date = 2.months.from_now
          course.save
          puts course.errors.empty? ? "New course: #{course.name}" : course.errors.full_messages

          # Create Project with the user in a group
          project = Project.new
          project.name = "#{Faker::Job.title} project"
          project.start_date = 1.month.ago
          project.end_date = 1.month.from_now
          project.start_dow = Date.yesterday.wday
          project.end_dow = Date.tomorrow.wday
          project.course = course
          project.factor_pack = FactorPack.find 1
          project.save
          puts project.errors.empty? ? "New project: #{project.name}" : project.errors.full_messages

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
            puts u.errors.empty? ? "New user: #{u.informal_name false}" : u.errors.full_messages
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
          puts group.errors.empty? ? "New group: #{group.name}" : group.errors.full_messages

          course.add_instructors_by_email user.email
          # Create an assignment that uses the rubric
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
          puts assignment.errors.empty? ? "New assignment: #{assignment.name}" : assignment.errors.full_messages

          submission = assignment.submissions.new(
            sub_text: Faker::Quote.yoda,
            submitted: Date.yesterday,
            user: group.users.sample
          )
          submission.save
          puts submission.errors.empty? ? "New submission: #{submission.id}" : submission.errors.full_messages
        end
      end
    end
  end

  desc 'Set email and password for user 1'
  task :haccess, [:email] => [:environment] do | _t, args |
    if args[:email].blank?
      puts '  This task sets up the initial admin user in CoLab dev environments'
      puts '  It will set the password to \'password\''
      puts '   Usage:   rake testing:haccess[<email>]'
    else

      puts 'running'
      if Rails.env.development?
        user = User.find_by( email: args[:email] )
        if user.nil?
          user = User.new(
            email: args[:email],
            admin: true,
            password: 'password',
            password_confirmation: 'password',
            welcomed: true,
            school_id: 1
          )
          user.confirm
        else
          user.admin = true
          user.welcomed = true
        end
        user.save
      else
        puts 'This only works in development'
      end
    end
  end

  desc 'Promote a user to an admin'
  task :set_admin, [:admin] => [:environment] do | _t, args |
    if 'true' != args[:admin] && 'false' != args[:admin]
      puts '  This task sets up administrators in CoLab test environments'
      puts '   Usage:   rake testing:set_admin[<new admin value>,<list of emails>]'
      puts "   Example: rake testing:set_admin['true','john_smith@gmail.com']"
      puts "   Example: rake testing:set_admin['false','john_smith@gmail.com']"
    else
      admin_value = 'true' == args[:admin]
      args.extras.each do | email |
        user = User.joins( :emails ).find_by( emails: { email: email } )
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
        # else
        user.admin = admin_value
        user.skip_confirmation!
        user.save
        if !user.errors.nil? && user.errors.count.positive?
          puts user.errors.full_messages
        else
          puts "#{user.name( false )} <#{email}> is admin? #{admin_value}"
        end
        # end
      end
    end
  end

  desc 'Run and report on our tests in parallel'
  task parallel_rpt: :environment do
    unless Rails.env.production?
      require 'report_builder'
      options = {
        input_path: 'cucumber/',
        report_path: 'test_results',
        report_title: 'CoLab BDD Test Results',
        report_types: %i[json html],
        voice_commands: true
      }
      ReportBuilder.build_report options
    end
  end

  desc 'Anonymize the current db contents'
  task :anon_db_init, [:times] => [:environment] do | _t, args |
    count = args[:times].to_i
    count = 2 if count < 2
    anonymization_salt = ENV.fetch( 'COLAB_ANON_DB_SALT', 'colab-anon-db-salt-v1' )
    digest_token = lambda do | key, id, size = 12 |
      Digest::SHA256.hexdigest( "#{anonymization_salt}:#{key}:#{id}" )[0, size]
    end
    deterministic_ratio = lambda do | key, id |
      digest_token.call( key, id, 12 ).to_i( 16 ) / 0xFFFFFFFFFFFF.to_f
    end
    min_age = 15
    age_span = 45
    age_skew_power = 5 # Higher values bias ages toward the younger bound.
    quasi_identifier_nil_rate = 0.25
    impairment_true_rate = 1.0 / 50
    redacted = ->( prefix, id ) { "[redacted-#{prefix}-#{id}]" }
    anon_email = ->( user_id, email_index = 0 ) { "user_#{user_id}_#{email_index}@example.invalid" }
    anon_subject = ->( prefix, id ) { "#{prefix} #{digest_token.call( prefix, id, 8 )}" }
    apply_email_anonymization = lambda do | email, user_id, email_index |
      email.email = anon_email.call( user_id, email_index )
      email.confirmation_token = nil
      email.unconfirmed_email = nil
      email.confirmation_sent_at = nil
      email.confirmed_at = Time.current
    end
    home_state_ids = HomeState.pluck( :id )
    cip_code_ids = CipCode.pluck( :id )

    count.times do | index |
      puts "Anonymizing DB contents, pass #{index + 1} of #{count}"
      Installment.transaction do
        Installment.find_each do | installment |
          installment.anonymize_comments if installment.anon_comments.blank? && installment.comments.present?
          if installment.anon_comments.blank?
            installment.anon_comments = redacted.call( 'installment-comment', installment.id )
          end
          installment.comments = installment.anon_comments
          installment.save! validate: false
        end

        School.find_each do | school |
          school.anon_name = anon_subject.call( 'School', school.id ) unless school.anon_name?
          school.name = school.anon_name
          school.description = redacted.call( 'school-description', school.id ) if school.description.present?
          school.save!
        end

        User.find_each do | user |
          user.anon_first_name = "User#{user.id}" unless user.anon_first_name?
          user.anon_last_name = "Anon#{digest_token.call( 'last', user.id, 6 )}" unless user.anon_last_name?
          user.first_name = user.anon_first_name
          user.last_name = user.anon_last_name
          if user.emails.size.positive?
            Email.transaction do
              user.emails.each_with_index do | email, index |
                apply_email_anonymization.call( email, user.id, index )
                email.save!
              end
            end
          else
            email = user.emails.new
            apply_email_anonymization.call( email, user.id, 0 )
            user.emails << email
            email.save!
          end
          primary_email = user.emails.order( :id ).first
          user.email = primary_email.email if primary_email.present?
          user.researcher = false
          user.confirmation_token = nil
          user.reset_password_token = nil
          user.unlock_token = nil
          user.unconfirmed_email = nil
          user.tokens = nil
          user.current_sign_in_ip = nil
          user.last_sign_in_ip = nil
          age = min_age + ( deterministic_ratio.call( 'date-of-birth-age', user.id )**age_skew_power * age_span ).floor
          user.date_of_birth = age.years.ago.to_date
          user.country = nil
          home_state_selector = deterministic_ratio.call( 'home-state-id', user.id )
          user.home_state_id = if home_state_ids.empty? || home_state_selector < quasi_identifier_nil_rate
                                 nil
                               else
                                 home_state_ids[
                                   [( home_state_selector * home_state_ids.size ).floor, home_state_ids.size - 1].min
                                 ]
                               end
          cip_selector = deterministic_ratio.call( 'cip-code-id', user.id )
          user.cip_code_id = if cip_code_ids.empty? || cip_selector < quasi_identifier_nil_rate
                               nil
                             else
                               cip_code_ids[[( cip_selector * cip_code_ids.size ).floor, cip_code_ids.size - 1].min]
                             end
          user.gender_id = nil
          user.started_school = nil
          user.impairment_auditory = deterministic_ratio.call( 'impairment-auditory', user.id ) < impairment_true_rate
          user.impairment_cognitive = deterministic_ratio.call( 'impairment-cognitive', user.id ) < impairment_true_rate
          user.impairment_motor = deterministic_ratio.call( 'impairment-motor', user.id ) < impairment_true_rate
          user.impairment_other = deterministic_ratio.call( 'impairment-other', user.id ) < impairment_true_rate
          user.impairment_visual = deterministic_ratio.call( 'impairment-visual', user.id ) < impairment_true_rate
          user.uid = if 'email' == user.provider
                       user.email
                     else
                       "anon-#{user.provider}-#{user.id}"
                     end
          user.save!
        end

        Group.find_each do | group |
          group.anon_name = anon_subject.call( 'Group', group.id ) unless group.anon_name?
          group.name = group.anon_name
          group.save!
        end

        BingoGame.find_each do | bingo_game |
          bingo_game.anon_topic = anon_subject.call( 'Bingo Topic', bingo_game.id ) unless bingo_game.anon_topic?
          bingo_game.topic = bingo_game.anon_topic
          if bingo_game.description.present?
            bingo_game.description = redacted.call( 'bingo-description', bingo_game.id )
          end
          bingo_game.save! validate: false
        end

        Experience.find_each do | experience |
          experience.anon_name = anon_subject.call( 'Experience', experience.id ) unless experience.anon_name?
          experience.name = experience.anon_name
          experience.save!
        end

        Project.find_each do | project |
          project.anon_name = anon_subject.call( 'Project', project.id ) unless project.anon_name?
          project.name = project.anon_name
          project.description = redacted.call( 'project-description', project.id ) if project.description.present?
          project.save! validate: false
        end

        Course.find_each do | course |
          course.anon_name = anon_subject.call( 'Course', course.id ) unless course.anon_name?
          course.anon_number = "CRS-#{course.id}" unless course.anon_number?
          course.name = course.anon_name
          course.number = course.anon_number
          course.description = redacted.call( 'course-description', course.id ) if course.description.present?
          course.save!
        end

        Assignment.find_each do | assignment |
          assignment.anon_name = anon_subject.call( 'Assignment', assignment.id ) unless assignment.anon_name?
          if assignment.anon_description.blank?
            assignment.anon_description = redacted.call( 'assignment-description', assignment.id )
          end
          assignment.name = assignment.anon_name
          assignment.description = assignment.anon_description
          assignment.save! validate: false
        end

        Rubric.find_each do | rubric |
          rubric.anon_name = anon_subject.call( 'Rubric', rubric.id ) unless rubric.anon_name?
          rubric.anon_description = redacted.call( 'rubric-description', rubric.id ) if rubric.anon_description.blank?
          rubric.name = rubric.anon_name
          rubric.description = rubric.anon_description
          rubric.save!
        end

        Submission.find_each do | submission |
          submission.sub_text = redacted.call( 'submission-text', submission.id ) if submission.sub_text.present?
          submission.sub_link = nil
          submission.save!
        end

        SubmissionFeedback.find_each do | submission_feedback |
          if submission_feedback.feedback.present?
            submission_feedback.feedback = redacted.call( 'submission-feedback', submission_feedback.id )
          end
          submission_feedback.save!
        end

        RubricRowFeedback.find_each do | rubric_row_feedback |
          if rubric_row_feedback.feedback.present?
            rubric_row_feedback.feedback = redacted.call( 'rubric-row-feedback', rubric_row_feedback.id )
          end
          rubric_row_feedback.save!
        end

        Diagnosis.find_each do | diagnosis |
          diagnosis.comment = redacted.call( 'diagnosis-comment', diagnosis.id ) if diagnosis.comment.present?
          diagnosis.other_name = nil
          diagnosis.save! validate: false
        end

        Reaction.find_each do | reaction |
          if reaction.improvements.present?
            reaction.improvements = redacted.call( 'reaction-improvements', reaction.id )
          end
          reaction.other_name = nil
          reaction.save! validate: false
        end

        ActiveRecord::SessionStore::Session.find_each do | session |
          # Session payload redaction can break legacy serializer expectations in SessionStore models.
          # Persist directly because these session rows are test fixtures, not user-facing records.
          session.update_columns( session_id: "anon-session-#{session.id}", data: '' )
        end
      end
    end
    ActiveRecord::Base.connection.execute( 'TRUNCATE ahoy_messages' )

    findings = []
    email_pattern = /[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}/i
    ip_pattern = /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
    token_pattern = /(bearer|token|oauth|refresh|access)[\s:_=-]+[A-Z0-9_-]{16,}/i
    jwt_pattern = /\beyJ[A-Z0-9_-]+\.[A-Z0-9_-]+\.[A-Z0-9_-]+\b/i

    Email.find_each do | email |
      findings << "email##{email.id}" unless email.email.ends_with?( '@example.invalid' )
    end
    User.find_each do | user |
      findings << "user-token##{user.id} (auth token field)" if user.tokens.present? ||
                                                                user.confirmation_token.present? ||
                                                                user.reset_password_token.present? ||
                                                                user.unlock_token.present?
      findings << "user-ip##{user.id} (ip field)" if user.current_sign_in_ip.present? || user.last_sign_in_ip.present?
      findings << "user-unconfirmed-email##{user.id} (unconfirmed email field)" if user.unconfirmed_email.present?
    end
    ActiveRecord::SessionStore::Session.find_each do | session |
      findings << "session##{session.id} (session payload)" if session.data.present?
    end
    [
      [Installment, :comments],
      [Submission, :sub_text],
      [SubmissionFeedback, :feedback],
      [RubricRowFeedback, :feedback],
      [Diagnosis, :comment],
      [Reaction, :improvements]
    ].each do | model, field |
      model.find_each do | record |
        value = record.public_send( field )
        next if value.blank?

        findings << "#{model.name}##{record.id}.#{field} (email-like)" if value.match?( email_pattern )
        findings << "#{model.name}##{record.id}.#{field} (ip-like)" if value.match?( ip_pattern )
        if value.match?( token_pattern ) || value.match?( jwt_pattern )
          findings << "#{model.name}##{record.id}.#{field} (token-like)"
        end
      end
    end
    if findings.any?
      shown = findings.take( 20 )
      raise(
        "PII residue detected (showing first #{shown.size} of #{findings.size}): " \
        "#{shown.join( ', ' )}. Review testing:anon_db_init and extend scrubbing rules."
      )
    end
  end
end

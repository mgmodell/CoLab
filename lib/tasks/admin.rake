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

  desc 'Cache performance numbers'
  task update_caches: :environment do
    CandidateList.joins(:bingo_game)
                 .where(cached_performance: nil, bingo_games: { reviewed: true })
                 .each do |candidate_list|
      candidate_list.performance
      candidate_list.save
    end
  end

  desc 'Get diversity information for a class'
  task :diversanal, [:course_id,:member_count] => [:environment] do |_t, args| 
    course = Course.where( id: args[:course_id].to_i ).take
    member_count = args[:member_count].to_i
    if course.nil? 
      puts '  This task analyses the student diversity in a class and '
      puts ' offers related analysis and data.'
      puts '   Usage:   rake admin:diversanal[<course_id>]'
      puts '   Example: rake admin:examples[7]'
    else
      puts "Diversity Analysis for #{course.name} (#{course.number})"
      if member_count.nil? || member_count < 2
        puts " 4 members per group"
        puts course.diversity_analysis.inspect
      else
        puts " #{member_count} members per group"
        puts course.diversity_analysis(member_count: member_count).inspect
      end
    end
  end

  desc 'Merge two users into one'
  task :merge_users, [:predator,:prey] => [:environment] do |_t, args|
    pred_e = args[:predator]
    prey_e = args[:prey]
    if prey_e.nil? || prey_e.empty? || pred_e.nil? || pred_e.empty?
      puts '  This task merges two users given their email addresses.'
      puts '   Usage:   rake admin:merge_users[<consumer email>,<consumed email>]'
      puts '   Example: rake admin:examples[\'john_smith@gmail.com\',\'john.smith@example.com\']'
      puts '   The above would absorb the example user into the gmail user'
    else
      #TODO Execute the code
      puts "#{pred_e} will consume #{prey_e}"
      User.merge_users predator: pred_e , prey: prey_e
    end
  end
end

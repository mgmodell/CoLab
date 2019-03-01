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


  desc 'Merge two users into one'
  task :merge_users, [:predator,:prey] => [:environment] do |_t, args|
    pred_e = args[:predator]
    prey_e = args[:prey]
    if prey_e.empty? or pred_e.empty?
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

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
    CandidateList.joins( :bingo_game )
        .where( cached_performance: nil, bingo_games: {reviewed: true} )
        .each do |candidate_list|
      candidate_list.performance 
    end

  end
end

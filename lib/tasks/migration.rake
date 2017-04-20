# frozen_string_literal: true
namespace :migratify do

  desc 'Set up infrastructure and send reminders and summaries'
  task april_20_2017: :environment do
    Assessment.where( instructor_updated: nil ).each do |a|
      a.instructor_updated = false
      a.save
    end
    Experience.where( instructor_updated: nil ).each do |e|
      e.instructor_updated = false
      e.save
    end
    Rake::Task['db:migrate'].invoke

#Add seed data
CandidateFeedback.create(name: 'Acceptable',
                         definition: "You've accurately identified and defined an important term related to the stated topic.")
CandidateFeedback.create(name: 'Definition: Incorrect',
                         definition: "You've identified an important term related to the stated topic, but the definition is wrong.")
CandidateFeedback.create(name: 'Definition: Insufficient',
                         definition: "You've identified an important term related to the stated topic, but the definition is incomplete in crucial ways.")
CandidateFeedback.create(name: 'Definition: Not Understood',
                         definition: "You've identified an important term related to the stated topic, but I was unable to understand the definition as you've provided it.")
CandidateFeedback.create(name: 'Definition: Plagiarised',
                         definition: "You've identified an important term related to the stated topic, but I recognize the definition provided as having been copied directly from another source.")
CandidateFeedback.create(name: 'Term: Too Genereic',
                         definition: 'The term is not specific to the topic or the course.')
CandidateFeedback.create(name: 'Term: Too Obvious',
                         definition: 'The term does not represent new learning or consideration relevant to the topic.')

  end
end

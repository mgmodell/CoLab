# frozen_string_literal: true
namespace :migratify do
  desc 'Make instructor_updated false'
  task falsify: :environment do
    Experience.all.each do |exp|
      exp.instructor_updated = false
      exp.save
    end

    Assessment.all.each do |asmt|
      asmt.instructor_updated = false
      asmt.save
    end
  end

  desc 'Get everything up to date with the current schema and seed data'
  task april_20_2017: :environment do
    # We should not need this one any longer.
    return
    Assessment.where(instructor_updated: nil).each do |a|
      a.instructor_updated = false
      a.save
      puts a.errors.full_messages unless a.errors.nil?
    end

    Experience.where(instructor_updated: nil).each do |e|
      e.instructor_updated = false
      e.save
      puts e.errors.full_messages unless e.errors.nil?
    end
    Rake::Task['db:migrate'].invoke

    # Add seed data
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

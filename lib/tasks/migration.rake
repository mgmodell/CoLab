# frozen_string_literal: true
namespace :migratify do
  desc 'Create the underpinnings for language support'
  task en_ko_lang: :environment do
    Rake::Task['db:migrate'].invoke

    #Seed data
    Language.create( name: "English: American", code: "en" ) if Language.where( code: "en" ).empty?
    Language.create( name: "Korean", code: "ko" ) if Language.where( code: "ko" ).empty?
  end

  desc 'Initialize existing PII objects with anonymized names'
  task anon_n_clean: :environment do
    # Make sure the DB is primed and ready!
    return
    Rake::Task['db:migrate'].invoke

    User.find_each do |user|
      user.anon_first_name = Forgery::Name.first_name if user.anon_first_name.blank?
      user.anon_last_name = Forgery::Name.last_name if user.anon_last_name.blank?
      user.researcher = false unless user.researcher.present?
      user.save
    end

    Group.find_each do |group|
      group.anon_name = "#{Forgery::Personal.language} #{Forgery::LoremIpsum.characters}s" if group.anon_name.blank?
      group.save
    end

    BingoGame.find_each do |bingo_game|
      bingo_game.anon_topic = Forgery::LoremIpsum.title.to_s if bingo_game.anon_topic.blank?
      bingo_game.save
    end

    Experience.find_each do |experience|
      experience.anon_name = Forgery::Name.company_name.to_s if experience.anon_name.blank?
      experience.save
    end

    Project.find_each do |project|
      project.anon_name = "#{Forgery::Address.country} #{Forgery::Name.job_title}" if project.anon_name.blank?
      project.save
    end

    School.find_each do |school|
      school.anon_name = "#{Forgery::Name.location} institute" if school.anon_name.blank?
      school.save
    end

    depts = %w(BUS MED ENG RTG MSM LEH EDP
               GEO IST MAT YOW GFB RSV CSV MBV)
    levels = %w(Beginning Intermediate Advanced)
    Course.find_each do |course|
      course.anon_name = "#{levels.sample} #{Forgery::Name.industry}"
      course.anon_number = "#{depts.sample}-#{rand(100..700)}"
      course.save
    end

    Candidate.find_each do |candidate|
      candidate.filtered_consistent =
        candidate.term.nil? ? '' :
        Candidate.filter.filter(candidate.term.strip.split.map(&:downcase)).join(' ')
      candidate.save
    end

    CandidateFeedback.create(name: 'Term: Doesn\'t match',
                             definition: 'The term does not match the definition.')
    CandidateFeedback.create(name: 'Term: Product Name',
                             definition: 'Products should not be used unless they are dominant/household name.')
  end

  desc 'Make instructor_updated false'
  task falsify: :environment do
    # We should not need this one any longer.
    return
    Experience.find_each do |exp|
      exp.instructor_updated = false
      exp.save
    end

    Assessment.find_each do |asmt|
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

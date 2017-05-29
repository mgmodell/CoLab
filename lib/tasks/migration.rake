# frozen_string_literal: true
namespace :migratify do
  desc 'Initialize existing PII objects with anonymized names'
  task anon_n_clean: :environment do
    # Make sure the DB is primed and ready!
    Rake::Task['db:migrate'].invoke

    User.all.each do |user|
      user.anon_first_name = Forgery::Name.first_name if user.anon_first_name.blank?
      user.anon_last_name = Forgery::Name.last_name if user.anon_last_name.blank?
      user.researcher = false unless user.researcher.present?
      user.save
    end

    Group.all.each do |group|
      group.anon_name = "#{Forgery::Personal.language} #{Forgery::LoremIpsum.characters}s" if group.anon_name.blank?
      group.save
    end

    BingoGame.all.each do |bingo_game|
      bingo_game.anon_topic = Forgery::LoremIpsum.title.to_s if bingo_game.anon_topic.blank?
      bingo_game.save
    end

    Experience.all.each do |experience|
      experience.anon_name = Forgery::Name.company_name.to_s if experience.anon_name.blank?
      experience.save
    end

    Project.all.each do |project|
      project.anon_name = "#{Forgery::Address.country} #{Forgery::Name.job_title}" if project.anon_name.blank?
      project.save
    end

    School.all.each do |school|
      school.anon_name = "#{Forgery::Name.location} institute" if school.anon_name.blank?
      school.save
    end

    depts = %w(BUS MED ENG RTG MSM LEH EDP
               GEO IST MAT YOW GFB RSV CSV MBV)
    Course.all.each do |course|
      course.anon_name = "Beginning #{Forgery::Name.industry}" if course.anon_name.blank?
      course.anon_number = "#{depts.sample}-#{rand(100..700)}" if course.anon_number.blank?
    end

    Candidate.all.each do |candidate|
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

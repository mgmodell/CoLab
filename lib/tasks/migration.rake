# frozen_string_literal: true
namespace :migratify do
  desc 'Create the underpinnings for language support'
  task db_updates: :environment do
    Rake::Task['db:migrate'].invoke

    # Quote seed data
    class Quote_
      attr_accessor :text_en, :attribution
    end
    read_data = YAML.safe_load(File.open('db/quotes.yml'), [Quote_])
    read_data.each do |quote|
      q = Quote.where(text_en: quote.text_en).take
      q = Quote.new if q.nil?
      q.text_en = quote.text_en unless q.text_en == quote.text_en
      q.attribution = quote.attribution unless q.attribution == quote.attribution
      q.save
    end

    # AgeRange seed data
    class AgeRange_
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/age_range.yml'), [AgeRange_])
    read_data.each do |age_range|
      g = AgeRange.where(name_en: age_range.name_en).take
      g = AgeRange.new if g.nil?
      g.name_en = age_range.name_en unless g.name_en == age_range.name_en
      g.name_ko = age_range.name_ko unless g.name_ko == age_range.name_ko
      g.save
    end

    # Gender seed data
    class Gender_
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/genders.yml'), [Gender_])
    read_data.each do |gender|
      g = Gender.where(name_en: gender.name_en).take
      g = Gender.new if g.nil?
      g.name_en = gender.name_en unless g.name_en == gender.name_en
      g.name_ko = gender.name_ko unless g.name_ko == gender.name_ko
      g.save
    end

    # FactorPack seed data
    class FactorPack_
      attr_accessor :name_en, :name_ko
      attr_accessor :description_en, :description_ko
    end
    read_data = YAML.safe_load(File.open('db/factor_pack.yml'), [FactorPack_])
    read_data.each do |factor_pack|
      g = FactorPack.where(name_en: factor_pack.name_en).take
      g = FactorPack.new if g.nil?
      g.name_en = factor_pack.name_en unless g.name_en == factor_pack.name_en
      g.name_ko = factor_pack.name_ko unless g.name_ko == factor_pack.name_ko
      g.description_en = factor_pack.description_en unless g.description_en == factor_pack.description_en
      g.description_ko = factor_pack.description_ko unless g.description_ko == factor_pack.description_ko
      g.save
    end

    # Factor seed data
    class Factor_
      attr_accessor :fp
      attr_accessor :name_en, :name_ko
      attr_accessor :description_en, :description_ko
    end
    read_data = YAML.safe_load(File.open('db/factor.yml'), [Factor_])
    read_data.each do |factor|
      g = Factor.where(name_en: factor.name_en).take
      g = Factor.new if g.nil?
      fp = FactorPack.where(name_en: factor.fp).take
      g.name_en = factor.name_en unless g.name_en == factor.name_en
      g.name_ko = factor.name_ko unless g.name_ko == factor.name_ko
      g.description_en = factor.description_en unless g.description_en == factor.description_en
      g.description_ko = factor.description_ko unless g.description_ko == factor.description_ko
      g.factor_pack = fp
      g.save
    end
  
    # Behavior seed data
    class Behavior_
      attr_accessor :name_en, :name_ko
      attr_accessor :description_en, :description_ko
    end
    read_data = YAML.safe_load(File.open('db/behavior.yml'), [Behavior_])
    read_data.each do |behavior|
      g = Behavior.where(name_en: behavior.name_en).take
      g = Behavior.new if g.nil?
      g.name_en = behavior.name_en unless g.name_en == behavior.name_en
      g.name_ko = behavior.name_ko unless g.name_ko == behavior.name_ko
      g.description_en = behavior.description_en unless g.description_en == behavior.description_en
      g.description_ko = behavior.description_ko unless g.description_ko == behavior.description_ko
      g.save
    end
    
    # Role seed data
    class Role_
      attr_accessor :code
      attr_accessor :name_en, :name_ko
      attr_accessor :description_en, :description_ko
    end
    read_data = YAML.safe_load(File.open('db/role.yml'), [Role_])
    read_data.each do |role|
      g = Role.where(name_en: role.name_en).take
      g = Role.new if g.nil?
      g.code = role.code unless g.code == role.code
      g.name_en = role.name_en unless g.name_en == role.name_en
      g.name_ko = role.name_ko unless g.name_ko == role.name_ko
      g.description_en = role.description_en unless g.description_en == role.description_en
      g.description_ko = role.description_ko unless g.description_ko == role.description_ko
      g.save
    end

    # Bingo! support
    class CandidateFeedback_
      attr_accessor :name_en, :name_ko
      attr_accessor :definition_en, :definition_ko
    end
    quote_data = YAML.safe_load(File.open('db/candidate_feedback.yml'), [CandidateFeedback_])
    quote_data.each do |cf|
      g = CandidateFeedback.where(name_en: cf.name_en).take
      g = CandidateFeedback.new if g.nil?
      g.name_en = cf.name_en unless g.name_en == cf.name_en
      g.name_ko = cf.name_ko unless g.name_ko == cf.name_ko
      g.definition_en = cf.definition_en unless g.definition_en == cf.definition_en
      g.definition_ko = cf.definition_ko unless g.definition_ko == cf.definition_ko
      g.save
    end
    
    # Theme seed data
    class Theme_
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/theme.yml'), [Theme_])
    read_data.each do |theme|
      g = Theme.where(name_en: theme.name_en).take
      g = Theme.new if g.nil?
      g.name_en = theme.name_en unless g.name_en == theme.name_en
      g.name_ko = theme.name_ko unless g.name_ko == theme.name_ko
      g.save
    end

    class Style_
      attr_accessor :name_en, :name_ko
      attr_accessor :filename
    end
    read_data = YAML.safe_load(File.open('db/style.yml'), [Style_])
    read_data.each do |style|
      g = Style.where(name_en: style.name_en).take
      g = Style.new if g.nil?
      g.name_en = style.name_en unless g.name_en == style.name_en
      g.name_ko = style.name_ko unless g.name_ko == style.name_ko
      g.filename = style.filename unless g.filename == style.filename
      g.save
    end


    # Multiple language support
    class Lang_
      attr_accessor :code
      attr_accessor :name_en, :name_ko
    end
    quote_data = YAML.safe_load(File.open('db/language.yml'), [Lang_])
    quote_data.each do |lang|
      g = Language.where(name_en: lang.name_en).take
      g = Language.new if g.nil?
      g.code = lang.code unless g.code == lang.code
      g.name_en = lang.name_en unless g.name_en == lang.name_en
      g.name_ko = lang.name_ko unless g.name_ko == lang.name_ko
      g.save
    end
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

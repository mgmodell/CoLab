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

    # Gender seed data
    class Gender_
      attr_accessor :code
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/genders.yml'), [Gender_])
    read_data.each do |gender|
      g = Gender.where('code = ? OR name_en = ?', gender.code, gender.name_en).take
      g = Gender.new if g.nil?
      g.code = gender.code unless g.code == gender.code
      g.name_en = gender.name_en unless g.name_en == gender.name_en
      g.name_ko = gender.name_ko unless g.name_ko == gender.name_ko
      g.save
    end

    # CIP Code seed data
    class CipCode_
      attr_accessor :gov_code
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/cip_constants.yml'), [CipCode_])
    read_data.each do |cip_code|
      g = CipCode.where(gov_code: cip_code.gov_code).take
      g = CipCode.new if g.nil?
      g.gov_code = cip_code.gov_code unless g.gov_code == cip_code.gov_code

      # Capitalize and strip trailing period
      cip_en = cip_code.name_en.chomp('.').capitalize
      g.name_en = cip_en unless
                    g.name_en == cip_en
      g.name_ko = cip_code.name_ko unless
                        g.name_ko == cip_code.name_ko
      g.save
    end

    # Commenting out this code because the Countries data is problematic
    ## Countries
    # CS.update # if CS.countries.count < 100
    # CS.countries.each do |country|
    #  hc = HomeCountry.where(code: country[0]).take
    #  hc = HomeCountry.new if hc.nil?
    #  hc.no_response = false
    #  hc.code = country[0]
    #  hc.name = country[1]
    #  hc.save
    # end
    # hc = HomeCountry.where(code: '__').take
    # hc = HomeCountry.new if hc.nil?
    # hc.no_response = true
    # hc.code = '__'
    # hc.name = 'I prefer not to specify my country'
    # hc.save

    ## States
    # HomeCountry.all.each do |country|

    #  if CS.get(country.code).count > 0
    #    CS.get(country.code).each do |state_code, state_name|
    #      hs = HomeState.where(home_country_id: country.id ).where( "code LIKE '%:#{country.code}").take
    #      hs = HomeState.new if hs.nil?
    #      hs.no_response = false
    #      hs.home_country = country
    #      hs.code = "#{state_code}:#{country.code}"
    #      hs.name = state_name
    #      hs.save
    #    end
    #    if CS.get(country.code).count > 1
    #      hs = HomeState.where(home_country_id: country.id, code: "__:#{country.code}").take
    #      hs = HomeState.new if hs.nil?
    #      hs.no_response = true
    #      hs.home_country = country
    #      hs.code = "__:#{country.code}"
    #      hs.name = 'I prefer not to specify the state'
    #      hs.save
    #    end
    #  else
    #    hs = HomeState.where(home_country_id: country.id, code: "--:#{country.code}").take
    #    hs = HomeState.new if hs.nil?
    #    hs.no_response = false
    #    hs.home_country = country
    #    hs.code = "--:#{country.code}"
    #    hs.name = 'not applicable'
    #    hs.save
    #  end
    # end

    User.find_each do |user|
      country = HomeCountry.where(name: user.country).take
      user.home_state = country.states.last unless country.nil?
      user.save
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

    # Concept init
    class Concept_
      attr_accessor :id, :name
    end

    concept_data = YAML.safe_load(File.open('db/concept.yml'), [Concept_])
    concept_data.each do |c|
      g = Concept.where(id: c.id).take
      g = Concept.new if g.nil?
      g.id = c.id
      g.name = c.name
      g.save
    end

    # Bingo! support
    class CandidateFeedback_
      attr_accessor :name_en, :name_ko
      attr_accessor :definition_en, :definition_ko
      attr_accessor :credit
    end
    quote_data = YAML.safe_load(File.open('db/candidate_feedback.yml'), [CandidateFeedback_])
    quote_data.each do |cf|
      g = CandidateFeedback.where(name_en: cf.name_en).take
      g = CandidateFeedback.new if g.nil?
      g.name_en = cf.name_en unless g.name_en == cf.name_en
      g.name_ko = cf.name_ko unless g.name_ko == cf.name_ko
      g.credit = cf.credit unless g.credit == cf.credit
      g.definition_en = cf.definition_en unless g.definition_en == cf.definition_en
      g.definition_ko = cf.definition_ko unless g.definition_ko == cf.definition_ko
      g.save
    end

    # Theme seed data
    class Theme_
      attr_accessor :code
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/theme.yml'), [Theme_])
    read_data.each do |theme|
      g = Theme.where(code: theme.code).take
      g = Theme.new if g.nil?
      g.code = theme.code unless g.code == theme.code
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

    translated = ['en']
    en_langs = I18nData.languages(:en)
    ko_langs = I18nData.languages(:ko)

    en_langs.keys.each do |lang_key|
      g = Language.where(code: lang_key.downcase).take
      g = Language.new if g.nil?
      g.code = lang_key.downcase unless g.code == lang_key.downcase
      g.name_en = en_langs[lang_key] unless g.name_en == en_langs[lang_key]
      g.name_ko = ko_langs[lang_key] unless g.name_ko == ko_langs[lang_key]
      g.translated = translated.include? lang_key.downcase
      g.save
    end
    g = Language.where(code: '__').take
    g = Language.new if g.nil?
    g.code = '__' unless g.code == '__'
    g.translated = false
    g.name_en = 'I prefer not to answer' unless g.name_en == 'I prefer not to answer'
    g.save

    class Scenario_
      attr_accessor :name_en, :name_ko
      attr_accessor :name_en, :name_ko
    end
    read_data = YAML.safe_load(File.open('db/scenario.yml'), [Scenario_])
    read_data.each do |scenario|
      g = Scenario.where(name_en: scenario.name_en).take
      g = Scenario.new if g.nil?
      b = Behavior.where(name_en: scenario.name_en).take
      if b.nil?
        puts "Could not find #{scenario.name_en} <Behavior>"
      else
        g.behavior = b
        g.name_en = scenario.name_en unless g.name_en == scenario.name_en
        g.name_ko = scenario.name_ko unless g.name_ko == scenario.name_ko
        g.save
      end
    end

    class Narrative_
      attr_accessor :scenario
      attr_accessor :member_en, :member_ko
    end
    read_data = YAML.safe_load(File.open('db/narrative.yml'), [Narrative_])
    read_data.each do |narrative|
      g = Narrative.where(member_en: narrative.member_en).take
      g = Narrative.new if g.nil?
      s = Scenario.where(name_en: narrative.scenario).take
      if s.nil?
        puts "Could not find #{scenario.name_en} <Scenario>"
      else
        g.scenario = s
        g.member_en = narrative.member_en unless g.member_en == narrative.member_en
        g.member_ko = narrative.member_ko unless g.member_ko == narrative.member_ko
        g.save
      end
    end

    # Scenario 1 (EC)
    narrative_names = %w[Alex Natasha Anika Lionel]
    class Week_
      attr_accessor :week_num
      attr_accessor :text_en, :text_ko
    end
    narrative_names.each do |name|
      narrative = Narrative.where(member_en: name).take
      if narrative.nil?
        puts "Could not find #{name} <Narrative>"
      else
        week_data = YAML.safe_load(File.open("db/narratives/ec_#{name.downcase}.yml"), [Week_])
        week_data.each do |week|
          w = Week.where(narrative: narrative, week_num: week.week_num).take
          w = Week.create(narrative: narrative, week_num: week.week_num) if w.nil?
          w.text_en = week.text_en unless w.text_en == week.text_en
          w.text_ko = week.text_ko unless w.text_ko == week.text_ko
          w.save
        end
      end
    end

    # Scenario 2 (GD)
    narrative_names = %w[Anna Jose Sam Kim]
    narrative_names.each do |name|
      narrative = Narrative.where(member_en: name).take
      if narrative.nil?
        puts "Could not find #{name} <Narrative>"
      else
        week_data = YAML.safe_load(File.open("db/narratives/gd_#{name.downcase}.yml"), [Week_])
        week_data.each do |week|
          w = Week.where(narrative: narrative, week_num: week.week_num).take
          w = Week.create(narrative: narrative, week_num: week.week_num) if w.nil?
          w.text_en = week.text_en unless w.text_en == week.text_en
          w.text_ko = week.text_ko unless w.text_ko == week.text_ko
          w.save
        end
      end
    end

    # Scenario 3 (SL)
    narrative_names = %w[John Marie Hannah Iain]
    narrative_names.each do |name|
      narrative = Narrative.where(member_en: name).take
      if narrative.nil?
        puts "Could not find #{name} <Narrative>"
      else
        week_data = YAML.safe_load(File.open("db/narratives/sl_#{name.downcase}.yml"), [Week_])
        week_data.each do |week|
          w = Week.where(narrative: narrative, week_num: week.week_num).take
          w = Week.create(narrative: narrative, week_num: week.week_num) if w.nil?
          w.text_en = week.text_en unless w.text_en == week.text_en
          w.text_ko = week.text_ko unless w.text_ko == week.text_ko
          w.save
        end
      end
    end
  end

  desc 'Initialize existing PII objects with anonymized names'
  task anon_n_clean: :environment do
    # Make sure the DB is primed and ready!

    User.find_each do |user|
      user.anon_first_name = Forgery::Name.first_name if user.anon_first_name.blank?
      user.anon_last_name = Forgery::Name.last_name if user.anon_last_name.blank?
      user.researcher = false unless user.researcher.present?
      user.save
    end

    Group.find_each do |group|
      group.anon_name = "#{rand < rand ? Forgery::Personal.language : Forgery::Name.location} #{Forgery::Name.company_name}s" if group.anon_name.blank?
      group.save
    end

    BingoGame.find_each do |bingo_game|
      if bingo_game.anon_topic.blank? || (bingo_game.anon_topic.starts_with? 'Lorem')
        trans = ['basics for a', 'for an expert', 'in the news with a novice', 'and Food Pyramids - for the']
        bingo_game.anon_topic = "#{Forgery::Name.company_name} #{trans.sample} #{Forgery::Name.job_title}"
        bingo_game.save
      end
    end

    Experience.find_each do |experience|
      experience.anon_name = Forgery::Name.company_name.to_s if experience.anon_name.blank?
      experience.save
    end

    Project.find_each do |project|
      project.anon_name = "#{rand < rand ? Forgery::Address.country : Forgery::Name.location} #{Forgery::Name.job_title}" if project.anon_name.blank?
      project.save
    end

    School.find_each do |school|
      school.anon_name = "#{rand < rand ? Forgery::Name.location : Forgery::Name.company_name} institute" if school.anon_name.blank?
      school.save
    end

    depts = %w[BUS MED ENG RTG MSM LEH EDP
               GEO IST MAT YOW GFB RSV CSV MBV]
    levels = %w[Beginning Intermediate Advanced]
    Course.find_each do |course|
      course.anon_name = "#{levels.sample} #{Forgery::Name.industry}" if course.anon_name.blank?
      course.anon_number = "#{depts.sample}-#{rand(100..700)}" if course.anon_number.blank?
      course.save
    end
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

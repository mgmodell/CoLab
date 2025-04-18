namespace :migratify do

  desc 'Set default theme color'
  task default_theme_colors_2025: :environment do
    User.where( theme: nil ).update_all( theme: '007bff' )

  end

  desc 'Updating the rails counter caches'
  task update_counters: :environment do
    ActiveRecord::Base.transaction do

      Reaction.find_each do |reaction|
        Reaction.reset_counters( reaction.id, :diagnoses )
      end

      CandidateList.find_each do |candidate_list|
        CandidateList.reset_counters( candidate_list.id, :candidates )
      end
      Concept.find_each do |concept|
        Concept.reset_counters( concept.id, :candidates )
      end

      School.find_each do |school|
        School.reset_counters( school.id, :courses )
      end
      ConsentForm.find_each do |consent_form|
        ConsentForm.reset_counters( consent_form.id, :courses )
      end

    end
  end

  desc 'Updating the DB to accommodate updated factors'
  task factor_update: :environment do
    # FactorPack seed data
    class FactorPack_
      attr_accessor :name_en, :name_ko
      attr_accessor :description_en, :description_ko
    end
    class Factor_
      attr_accessor :fp
      attr_accessor :name_en, :name_ko
      attr_accessor :description_en, :description_ko
    end
    ActiveRecord::Base.transaction do
      read_data = YAML.load_file(
        'db/factor_pack.yml',
        permitted_classes: [FactorPack_]
        )
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
      read_data = YAML.load_file(
        'db/factor.yml',
        permitted_classes: [Factor_]
      )
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
    end
  end

  desc 'Applying for the react migration in the summer of 2020'
  task api_conversion: :environment do
    behavior = Behavior.find_by_name_en( 'Other' )
    behavior.needs_detail = true
    behavior.save

    User.all.each do |u|
      u.update_instructor
      u.save
    end

    Course.all.each do |c|
      c.anon_offset = - Random.rand(1000).days.to_i + 35
      c.save
    end

  end

  desc 'Update the quotes again'
  task quotes: :environment do
    # Quote seed data
    class Quote_
      attr_accessor :text_en, :attribution
    end
    read_data = YAML.load_file(
      'db/quotes.yml',
      permitted_classes: [Quote_])
    read_data.each do |quote|
      quote.text_en = quote.text_en.strip
      q = Quote.where(text_en: quote.text_en).take
      q = Quote.new if q.nil?
      q.text_en = quote.text_en unless q.text_en == quote.text_en
      q.attribution = quote.attribution unless q.attribution == quote.attribution
      q.save
    end

  end

  # older tasks
  desc 'Applying changes to Candidate Feedback options'
  task cf_updates: :environment do

    CandidateFeedback.transaction do
      cf = CandidateFeedback.where name_en: 'Definition: Insufficient'
      if 1 == cf.size
        cf = cf[ 0 ]
        cf.name_en = 'Definition: Almost correct'
        cf.definition_en =
          "You've identified an important term related to the stated topic and " +
          "provided a definition that is close to complete, but is lacking in " +
          "some crucial way(s)."
        cf.save
      else
        puts "Error on insufficient: #{cf.size} items found"
      end

      cf = CandidateFeedback.where name_en: 'Definition: Plagiarised'
      if 1 == cf.size
        cf = cf[ 0 ]
        cf.name_en = 'Definition: Borrowed Word-for-Word'
        cf.save
      else
        puts "Error on plagiarised: #{cf.size} items found"
      end

      remap_to_id = -1
      cf = CandidateFeedback.where name_en: 'Term: Proper Name'
      if 1 == cf.size
        cf = cf[ 0 ]
        remap_to_id = cf.id
        cf.name_en = 'Term: Proper Name or Product Name'
        cf.definition_en =
          "Proper names and products should not be used unless they are "+
          "dominant to the point of being synonymous with a class of " +
          "activity or a household name."
        cf.save

        cf = CandidateFeedback.where name_en: 'Term: Product Name'
        if 1 == cf.size
          remap_from_id = cf[0].id
          # Remap 11 (proper name) to 12 (product name)
          Candidate.where( candidate_feedback_id: remap_from_id )
            .update_all( candidate_feedback_id: remap_to_id )
          if 0 < CandidateFeedback.where( id: remap_from_id ).size
            CandidateFeedback.destroy( remap_from_id )
          end
        end
      else
        puts "Error on proper: #{cf.size} items found"
      end

      #Standardize concept names
      Concept.all.each do |concept|
        concept.name = Concept.standardize_name name: concept.name
        concept.save
      end

    end

  end


  desc 'Adding type to Candidate Feedback'
  task cf_type: :environment do
    CandidateFeedback.all.each do |cf|
      if 'Acceptable' == cf.name_en
        cf.critique = 1

      elsif cf.name_en.start_with? 'Definition'
        cf.critique = 2

      end
      cf.save

    end

  end

  desc 'lead time fixes'
  task lead_time: :environment do
    # Uupdate the lead times for bingo games
    BingoGame.all.each do |bg|
      bg.lead_time = bg.lead_time - 1
      bg.save( validate: false )
      puts bg.errors.full_messages unless bg.errors.empty?
    end

    # Update the lead times for bingo games
    Experience.all.each do |exp|
      exp.lead_time = 2
      exp.end_date = exp.end_date + exp.lead_time.days
      exp.save( validate: false )
      puts exp.errors.full_messages unless exp.errors.empty?
    end

  end

  desc 'Candidates fix'
  task candidate_fix: :environment do
    CandidateList.transaction do
      CandidateList.where( 'group_id is not null' ).each do |cl|
        cl.contributor_count = cl.group.users.size
        cl.save!

        #Archive the old ones
        cl.group.users.each do |u|
          cl_arch = CandidateList.where(
            user: u,
            bingo_game: cl.bingo_game )
          raise "Too many lists for u:#{u.id} b:#{cl.bingo_game_id}" unless cl_arch.size == 1

          cl_arch = cl_arch[ 0 ]
          cl_arch.archived = true
          cl_arch.is_group = false
          cl_arch.current_candidate_list = cl
          cl_arch.save!
        end
      end
    end

    CandidateList.where( 'user_id IS NOT NULL' ).where( is_group: true).each do |cl|
      group = GroupRevision
              .where( 'members LIKE "%? %" AND updated_at < ?', cl.user_id, cl.updated_at)
              .take
              .group
      g_cl = CandidateList.where(
        is_group: true,
        group: group,
        bingo_game: cl.bingo_game )
      g_cl = g_cl[0]
      g_cl.contributor_count = g_cl.contributor_count + 1
      g_cl.cached_performance = nil
      g_cl.save
      cl.archived = true
      cl.is_group = false
      cl.current_candidate_list = g_cl
      cl.save
    end
  end



  desc 'Update the quotes again'
  task mar_2019: :environment do
    # Quote seed data
    class Quote_
      attr_accessor :text_en, :attribution
    end
    read_data = YAML.safe_load(File.open('db/quotes.yml'), [Quote_])
    read_data.each do |quote|
      quote.text_en = quote.text_en.strip
      q = Quote.where(text_en: quote.text_en).take
      q = Quote.new if q.nil?
      q.text_en = quote.text_en unless q.text_en == quote.text_en
      q.attribution = quote.attribution unless q.attribution == quote.attribution
      q.save
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
  end


  desc 'Update the quotes'
  task jan_2019: :environment do
    # Quote seed data
    class Quote_
      attr_accessor :text_en, :attribution
    end
    read_data = YAML.safe_load(File.open('db/quotes.yml'), [Quote_])
    read_data.each do |quote|
      quote.text_en = quote.text_en.strip
      q = Quote.where(text_en: quote.text_en).take
      q = Quote.new if q.nil?
      q.text_en = quote.text_en unless q.text_en == quote.text_en
      q.attribution = quote.attribution unless q.attribution == quote.attribution
      q.save
    end

    Concept.all.each do |concept|
      Concept.reset_counters( concept.id, :candidate_lists )
      concept.bingo_games_count = concept.bingo_games.uniq.size
      concept.courses_count = concept.courses.uniq.size
      concept.save
    end

  end


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
      user.anon_first_name = Faker::Name.first_name unless user.anon_first_name?
      user.anon_last_name = Faker::Name.last_name unless user.anon_last_name?
      user.researcher = false unless user.researcher?
      user.save
    end

    Group.find_each do |group|
      unless group.anon_name?
        group.anon_name = "#{rand < rand ? Faker::Nation.language : Faker::Nation.nationality} #{Faker::Company.name}s"
      end
      group.save
    end

    BingoGame.find_each do |bingo_game|
      if !bingo_game.anon_topic? || (bingo_game.anon_topic.starts_with? 'Lorem')
        trans = ['basics for a', 'for an expert', 'in the news with a novice', 'and Food Pyramids - for the']
        bingo_game.anon_topic = "#{Faker::Company.catch_phrase} #{trans.sample} #{Faker::Job.title}"
        bingo_game.save
      end
    end

    Experience.find_each do |experience|
      experience.anon_name = "#{Faker::Company.industry} #{Faker::Company.suffix}" unless experience.anon_name?
      experience.save
    end

    locations = [
      Faker::Games::Pokemon,
      Faker::Games::Touhou,
      Faker::Games::Overwatch,
      Faker::Movies::HowToTrainYourDragon,
      Faker::Fantasy::Tolkien
    ]
    Project.find_each do |project|
      project.anon_name = "#{locations.sample.location} #{Faker::Job.field}" unless project.anon_name?
      project.save
    end

    School.find_each do |school|
      school.anon_name = "#{Faker::Color.color_name} #{Faker::Educator.university}" unless school.anon_name?
      school.save
    end

    depts = %w[BUS MED ENG RTG MSM LEH EDP
               GEO IST MAT YOW GFB RSV CSV MBV]
    levels = %w[Beginning Intermediate Advanced]
    Course.find_each do |course|
      course.anon_name = "#{levels.sample} #{Faker::Company.industry}" unless course.anon_name?
      course.anon_number = "#{depts.sample}-#{rand(100..700)}" unless course.anon_number?
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

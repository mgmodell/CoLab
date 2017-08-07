# frozen_string_literal: true

# Foundational data
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

  #Capitalize and strip trailing period
  cip_en = cip_code.name_en.chomp( '.' ).capitalize
  g.name_en = cip_en unless
                    g.name_en == cip_en
  g.name_ko = cip_code.name_ko unless
                    g.name_ko == cip_code.name_ko
  g.save
end

# Countries
CS.countries.each do |country|
  hc = HomeCountry.where( code: country[ 0 ] ).take
  hc = HomeCountry.new if hc.nil?
  hc.code = country[ 0 ]
  hc.name = country[ 1 ]
  hc.save
end
hc = HomeCountry.where( code: '__' ).take
hc = HomeCountry.new if hc.nil?
hc.code = '__' unless hc.code == '__'
hc.name = 'I prefer not to specify my country' unless
          hc.name == 'I prefer not to specify my country'
hc.save

# States
HomeCountry.all.each do |country|
  if CS.get( country.code ).count > 0
    CS.get( country.code ).each do |state|
      hs = HomeState.where( home_country_id: country.id, code: state[ 0 ] ).take
      hs = HomeState.new if hs.nil?
      hs.home_country = country
      hs.code = state[ 0 ]
      hs.name = state[ 1 ]
      hs.save
    end
    hs = HomeState.where( home_country_id: country.id, code: '__' ).take
    hs = HomeState.new if hs.nil?
    hs.home_country = country
    hs.code = '__'
    hs.name = 'I prefer not to specify the state'
    hs.save
  else
    hs = HomeState.where( home_country_id: country.id, code: '--' ).take
    hs = HomeState.new if hs.nil?
    hs.home_country = country
    hs.code = '--'
    hs.name = 'not applicable'
    hs.save
  end
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

# Gender seed data
class Gender_
  attr_accessor :code
  attr_accessor :name_en, :name_ko
end
read_data = YAML.safe_load(File.open('db/genders.yml'), [Gender_])
read_data.each do |gender|
  g = Gender.where(code: gender.code).take
  g = Gender.new if g.nil?
  g.code = gender.code unless g.code == gender.code
  g.name_en = gender.name_en unless g.name_en == gender.name_en
  g.name_ko = gender.name_ko unless g.name_ko == gender.name_ko
  g.save
end

School.create(name: 'Indiana University', description: 'A large, Midwestern university')
School.create(name: 'SUNY Korea', description: 'The State University of New York, Korea')

u = User.new(first_name: 'Micah',
             last_name: 'Modell',
             admin: true,
             password: 'testest',
             password_confirmation: 'testest',
             email: 'micah.modell@gmail.com',
             timezone: 'UTC')
u.skip_confirmation!
u.save

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

class Scenario_
  attr_accessor :name_en, :name_ko
  attr_accessor :name_en, :name_ko
end
read_data = YAML.safe_load(File.open('db/scenario.yml'),[Scenario_])
read_data.each do |scenario|
  g = Scenario.where( name_en: scenario.name_en ).take
  g = Scenario.new if g.nil?
  b = Behavior.where( name_en: scenario.name_en ).take
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
  s = Scenario.where( name_en: narrative.scenario ).take
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
narrative_names = ['Alex','Natasha','Anika','Lionel']
class Week_
  attr_accessor :week_num
  attr_accessor :text_en, :text_ko
end
narrative_names.each do |name|
  narrative = Narrative.where( member_en: name ).take
  if narrative.nil?
    puts "Could not find #{name} <Narrative>"
  else
    f_name = "db/narratives/ec_#{name.downcase}.yml"
    week_data = YAML.safe_load(File.open(f_name), [Week_])
    week_data.each do |week|
      w = Week.where( narrative: narrative, week_num: week.week_num ).take
      w = Week.create( narrative: narrative, week_num: week.week_num ) if w.nil?
      w.text_en = week.text_en unless w.text_en == week.text_en
      w.text_ko = week.text_ko unless w.text_ko == week.text_ko
      w.save
    end
  end
end

# Scenario 2 (GD)
narrative_names = ['Anna','Jose','Sam','Kim']
narrative_names.each do |name|
  narrative = Narrative.where( member_en: name ).take
  if narrative.nil?
    puts "Could not find #{name} <Narrative>"
  else
    f_name = "db/narratives/gd_#{name.downcase}.yml"
    week_data = YAML.safe_load(File.open(f_name), [Week_])
    week_data.each do |week|
      w = Week.where( narrative: narrative, week_num: week.week_num ).take
      w = Week.create( narrative: narrative, week_num: week.week_num ) if w.nil?
      w.text_en = week.text_en unless w.text_en == week.text_en
      w.text_ko = week.text_ko unless w.text_ko == week.text_ko
      w.save
    end
  end
end

# Scenario 3 (SL)
narrative_names = ['John','Marie','Hannah','Iain']
narrative_names.each do |name|
  narrative = Narrative.where( member_en: name ).take
  if narrative.nil?
    puts "Could not find #{name} <Narrative>"
  else
    f_name = "db/narratives/sl_#{name.downcase}.yml"
    week_data = YAML.safe_load(File.open(f_name), [Week_])
    week_data.each do |week|
      w = Week.where( narrative: narrative, week_num: week.week_num ).take
      w = Week.create( narrative: narrative, week_num: week.week_num ) if w.nil?
      w.text_en = week.text_en unless w.text_en == week.text_en
      w.text_ko = week.text_ko unless w.text_ko == week.text_ko
      w.save
    end
  end
end

class Quote_
  attr_accessor :text_en, :attribution
end
quote_data = YAML.safe_load(File.open('db/quotes.yml'), [Quote_])
quote_data.each do |quote|
  q = Quote.where(text_en: quote.text_en).take
  q = Quote.new if q.nil?
  q.text_en = quote.text_en
  q.attribution = quote.attribution
  q.save
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

translated = [ 'en' ]
en_langs = I18nData.languages( :en )
ko_langs = I18nData.languages( :ko )

en_langs.keys.each do |lang_key|
  g = Language.where(code: lang_key.downcase).take
  g = Language.new if g.nil?
  g.code = lang_key.downcase unless g.code == lang_key.downcase
  g.translated = translated.include? lang_key.downcase
  g.name_ko = ko_langs[ lang_key ] unless g.name_ko == ko_langs[ lang_key ]
  g.name_en = en_langs[ lang_key ] unless g.name_en == en_langs[ lang_key ]
  g.save
end

g = Language.where(code: '__').take
g = Language.new if g.nil?
g.code = '__' unless g.code == '__'
g.translated = false
g.name_en = 'I prefer not to answer' unless g.name_en == 'I prefer not to answer'
g.save

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

GroupProjectCount.create(name: 'none',
                         description: "I don't remember having been a part of a long-term group project.")
GroupProjectCount.create(name: 'few',
                         description: 'I have been a part of one to five long-term group projects.')
GroupProjectCount.create(name: 'some',
                         description: 'I have been a part of five to ten long-term group projects.')

School.create(name: 'Indiana University', description: 'A large, Midwestern university')
School.create(name: 'SUNY Korea', description: 'The State University of New York, Korea')

Theme.create(name: 'MJ', code: 'a')
Theme.create(name: 'Maverick', code: 'b')
Theme.create(name: 'Peppermint', code: 'c')
Theme.create(name: 'Manhattan', code: 'd')
Theme.create(name: 'Carrot', code: 'e')
Theme.create(name: 'Hot Dog Stand', code: 'f')
Theme.create(name: 'Decepticon', code: 'g')
Theme.create(name: 'just one', code: 'h')

Style.create(name: 'Default', filename: 'new')
Style.create(name: 'Sliders (simple)', filename: 'slider_basic')
Style.create(name: 'buttons (simple)', filename: 'button_basic')

u = User.new(first_name: 'Micah',
             last_name: 'Modell',
             admin: true,
             password: 'testest',
             password_confirmation: 'testest',
             email: 'micah.modell@gmail.com',
             timezone: 'UTC')
u.skip_confirmation!
u.save

# Scenario content here
Scenario.create(name: 'Equal Participation', behavior_id: 1)
Scenario.create(name: 'Group Domination', behavior_id: 3)
Scenario.create(name: 'Social Loafing', behavior_id: 4)

# Scenario 1 (EC)
Narrative.create(member: 'Alex', scenario_id: 1)
Narrative.create(member: 'Natasha', scenario_id: 1)
Narrative.create(member: 'Anika', scenario_id: 1)
Narrative.create(member: 'Lionel', scenario_id: 1)

class Week_
  attr_accessor :week_num, :text
end

week_data = YAML.safe_load(File.open('db/narratives/ec_alex.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 1,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/ec_natasha.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 2,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/ec_anika.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 3,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/ec_lionel.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 4,
    week_num: week.week_num,
    text: week.text
  )
end

# Scenario 2 (GD)
Narrative.create(member: 'Anna', scenario_id: 2)
Narrative.create(member: 'Jose', scenario_id: 2)
Narrative.create(member: 'Sam', scenario_id: 2)
Narrative.create(member: 'Kim', scenario_id: 2)

week_data = YAML.safe_load(File.open('db/narratives/gd_anna.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 5,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/gd_jose.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 6,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/gd_sam.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 7,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/gd_kim.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 8,
    week_num: week.week_num,
    text: week.text
  )
end

# Scenario 3 (SL)
# Scenario 3 (SL)
Narrative.create(member: 'John', scenario_id: 3)
Narrative.create(member: 'Marie', scenario_id: 3)
Narrative.create(member: 'Hannah', scenario_id: 3)
Narrative.create(member: 'Iain', scenario_id: 3)

week_data = YAML.safe_load(File.open('db/narratives/sl_john.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 9,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/sl_marie.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 10,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/sl_hannah.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 11,
    week_num: week.week_num,
    text: week.text
  )
end

week_data = YAML.safe_load(File.open('db/narratives/sl_iain.yml'), [Week_])
week_data.each do |week|
  Week.create(
    narrative_id: 12,
    week_num: week.week_num,
    text: week.text
  )
end

class Cip_
  attr_accessor :id, :description
end

cip_data = YAML.safe_load(File.open('db/cip_constants.yml'), [Cip_])
cip_data.each do |cip_code|
  CipCode.create(
    gov_code: cip_code.id,
    description: cip_code.description
  )
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
CandidateFeedback.create(name: 'Term: Too Generic',
                         definition: 'The term is not specific to the topic or the course.')
CandidateFeedback.create(name: 'Term: Too Obvious',
                         definition: 'The term does not represent new learning or consideration relevant to the topic.')
CandidateFeedback.create(name: 'Term: Invalid/Incorrect',
                         definition: 'The term is either not a real term or one that does not relate to the topic.')
CandidateFeedback.create(name: 'Term: Not relevant',
                         definition: 'The term is not relevant to the topic.')
CandidateFeedback.create(name: 'Term: Doesn\'t match',
                         definition: 'The term does not match the definition.')
CandidateFeedback.create(name: 'Term: Product Name',
                         definition: 'Products should not be used unless they are dominant/household name.')
# Multiple language support
Language.create(name: 'English: American', code: 'en')
Language.create(name: 'Korean', code: 'ko')

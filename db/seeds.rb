# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

# Foundational data
bp = FactorPack.create(name: 'Simple', description: 'Borrowed from Goldfinch')
Factor.create(name: 'Organizing', description: 'Helped to organize the group''s members and activities.', factor_packs: [bp])
Factor.create(name: 'Understanding requirements', description: 'Understanding what was required of the group and of the individual group members.', factor_packs: [bp])
Factor.create(name: 'Suggesting ideas', description: 'Suggesting ideas upon which the group could act or continue to build productively.', factor_packs: [bp])
Factor.create(name: 'Producing', description: 'Coming up with something useful to contribute to the group''s efforts.', factor_packs: [bp])
Factor.create(name: 'Performing tasks', description: 'Performing tasks allocated by the group within the specified timeframe.', factor_packs: [bp])
# Create a new BP
bp = FactorPack.create(name: 'Original', description: 'My earliest formulation')
Factor.create(name: 'Work', description: 'Performing tasks allocated by the group within the specified timeframe.', factor_packs: [bp])
Factor.create(name: 'Creativity', description: 'Performing tasks allocated by the group within the specified timeframe.', factor_packs: [bp])
Factor.create(name: 'Group Dynamics', description: 'Performing tasks allocated by the group within the specified timeframe.', factor_packs: [bp])
# Create a new BP
bp = FactorPack.create(name: 'Distilled I', description: 'Distillation of factors from initial set of 23 sources')
Factor.create(name: 'Standards', description: 'Establishing standards for quality and evaluating group performance and decisions in relation to these standards.', factor_packs: [bp])
Factor.create(name: 'Constructive criticism', description: 'Delivering constructive criticism.', factor_packs: [bp])
Factor.create(name: 'Valuing teammates', description: 'Valuing the contributions of teammates; maintaining a positive attitude and encouraging a positive attitude in teammates.', factor_packs: [bp])
Factor.create(name: 'Facilitating communications', description: 'Facilitating communications between teammates; helping members understand one another.', factor_packs: [bp])
Factor.create(name: 'Ideas and suggestions', description: 'Contributing ideas and suggestions to the group.', factor_packs: [bp])
Factor.create(name: 'New information', description: 'Bringing new and relevant information to the group.', factor_packs: [bp])
Factor.create(name: 'Integrating ideas', description: 'Interpreting, consolidating and integrating ideas and information into a useful result.', factor_packs: [bp])
Factor.create(name: 'Accepting tasks', description: 'Accepting suggested tasks and/or volunteering for new ones.', factor_packs: [bp])
Factor.create(name: 'Time-sensitive', description: 'Performing assigned tasks on time and/or notifying the group in a timely fashion when assigned tasks cannot be completed for any reason (e.g. wrong task, insufficient information, insufficient time, etc.)', factor_packs: [bp])
Factor.create(name: 'Relevant questions', description: "Asking questions relevant to understanding the group's goals or how to achieve them. This includes questions aimed at understanding teammates' ideas and suggestions.", factor_packs: [bp])
Factor.create(name: 'External communications', description: "Representing or demonstrating the group's progress, goals and/or positions effectively and accurately to non-members (orally, visually or otherwise).", factor_packs: [bp])
Factor.create(name: 'Timeline management', description: "Managing the development of, adherence to and revision of the group's specific timeline.", factor_packs: [bp])
Factor.create(name: 'Allocating resources', description: 'Suggesting allocation of resources (team members, materials, etc.) to individual task completions.', factor_packs: [bp])

Behavior.create(
  name: 'Equal participation',
  description: "Each group member's contributions toward the group's
    effort are roughly equal. There will be variability in the types of
    contributions, and individuals may see ups and downs, but the overall
    responsibility is being fairly shared. <i>If no other behavior is clearly
    dominant, select this option</i>."
)

Behavior.create(
  name: 'Ganging up on the task',
  description: "This is when only one member of the group engages with the
    task at hand and the others actively avoid it.  The engaged member becomes
    overwhelmed, and joins the rest of the group in avoidance activities."
)

Behavior.create(
  name: 'Group domination',
  description: "This is when an individual asserts his or her authority
    through some combination of commanding other members and controlling
    conversation. This often involves the individual interrupting and otherwise
    devaluing the contributions of others."
)

Behavior.create(
  name: 'Social loafing',
  description: "This is when an individual consistently under-contributes to
    the efforts of the group to achieve its goals. This forces other group
    members to do extra work so the task can be completed successfully."
)

Behavior.create(
  name: "I don't know",
  description: "I am not sure which group behavior dominates this entry, but
    it is not equal participation."
)

Behavior.create(
  name: 'Other',
  description: "This entry indicates a behavior that is not listed and I will
    enter it in myself."
)

Role.create(name: 'Instructor',
            description: 'This user teaches the course.')
Role.create(name: 'Assistant',
            description: 'This user assists the course instructor.')
Role.create(name: 'Enrolled Student',
            description: 'This user is a student in this class.')
Role.create(name: 'Invited Student',
            description: 'This user is a student that has been invited to participatein this class.')
Role.create(name: 'Declined Student',
            description: 'This user is a student that has declined to participate in this class.')
Role.create(name: 'Dropped Student',
            description: 'This user is a student that was enrolled but is not any longer.')

AgeRange.create(name: '<18')
AgeRange.create(name: '18-20')
AgeRange.create(name: '21-25')
AgeRange.create(name: '25-30')
AgeRange.create(name: '31+')
AgeRange.create(name: "I'd prefer not to answer")

Gender.create(name: 'Male')
Gender.create(name: 'Female')
Gender.create(name: "I'd prefer not to answer")

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
CandidateFeedback.create(name: 'Term: Too Genereic',
                         definition: 'The term is not specific to the topic or the course.')
CandidateFeedback.create(name: 'Term: Too Obvious',
                         definition: 'The term does not represent new learning or consideration relevant to the topic.')

# frozen_string_literal: true

require 'faker'

Then(/^the user clicks the link to the experience$/) do
  wait_for_render
  step 'the user switches to the "Task View" tab'
  find(:xpath, "//tbody/tr/td[text()='#{@experience.name}']").click
end

Then 'the {string} button will be disabled' do |button_name|
  wait_for_render
  elem = find(:xpath, "//button[contains(.,'#{button_name}')]")
  elem[:disabled].should eq 'true'
end

Then 'the user will see {string}' do |check_text|
  wait_for_render
  should have_content check_text
end

Then(/^the user presses hidden "([^"]*)"$/) do |link_or_button_name|
  click_link_or_button link_or_button_name, visible: :all, disabled: :all
end

Then(/^the user presses "([^"]*)"$/) do |link_or_button_name|
  click_link_or_button link_or_button_name
end

Then(/^they open the drawer for additional comments$/) do
  wait_for_render
  find(:xpath,
       "//div/a[contains(.,'Click here if you have additional comments for us regarding this narrative.')]").click
end

Then(/^they enter "([^"]*)" in extant field "([^"]*)"$/) do |txt, fld|
  label = find(:xpath, "//label[text()='#{fld}']")
  element = if has_xpath?("//input[@id='#{label[:for]}']")
              find(:xpath, "//input[@id='#{label[:for]}']")
            else
              find(:xpath, "//textarea[@id='#{label[:for]}']")
            end
  # element = find(:xpath, "//textarea[@id='#{label[:for]}']")
  element.click
  element.send_keys txt
end

Then(/^in the field "([^"]*)" they will see "([^"]*)"$/) do |fld, value|
  label = find(:xpath, "//label[text()='#{fld}']")
  panel = all(:xpath, "//textarea[@id='#{label[:for]}']")
  panel[0].click unless panel.empty?
  # click_link_or_button 'Click here if you have additional comments for us regarding this narrative.'
  field_value = panel[0].value
  expect(field_value).to include value
end

Then(/^the user chooses the "([^"]*)" radio button$/) do |choice|
  elem = find(:xpath, "//label[contains(.,\"#{choice}\")]")
  elem.click
end

Then(/^the database will show a new week (\d+) "([^"]*)" diagnosis from the user$/) do |week_num, behavior|
  wait_for_render
  diagnosis = Diagnosis.joins(:reaction).where(reactions: { user_id: @user.id }).last
  diagnosis.week.week_num.should eq week_num.to_i
  diagnosis.behavior.name_en.should eq behavior
end

Then(/^the latest Diagnosis will show "([^"]*)" in the field "([^"]*)"$/) do |_value, fld|
  diagnosis = Diagnosis.last
  case fld.downcase
  when 'comment'
    diagnosis.comment.should eq fld
  when 'other_text'
    diagnosis.other_name.should eq fld
  end
end

Then(/^the user sees the experience instructions page$/) do
  wait_for_render
  step 'the user will see "Instructions for completing"'
end

Then(/^the user completes a week$/) do
  reaction = @experience.get_user_reaction @user
  week = reaction.next_week
  # get the current week number

  wait_for_render
  behavior = Behavior.all.to_a.sample
  step_text = "the user will see \"Week #{week.week_num}\""
  step step_text
  step_text = "the user chooses the \"#{behavior.name_en}\" radio button"
  step step_text
  step_text = 'they enter "FUBAR" in extant field "What behavior did you see?"'
  # Only enter behavior name if 'Other' is selected
  step step_text if 'Other' == behavior.name_en
  step_text = 'the user presses "Save and continue"'
  step step_text
  wait_for_render
  step_text = "the database will show a new week #{week.week_num} \"#{behavior.name_en}\" diagnosis from the user"
  step step_text
  ack_messages
end

Then(/^the database will show a reaction with "([^"]*)" as the behavior$/) do |behavior|
  wait_for_render
  reaction = Reaction.last
  reaction.behavior.name_en.should eq behavior
end

Then(/^the database will show a reaction for the user with "([^"]*)" as the behavior$/) do |behavior|
  wait_for_render
  Reaction.where(user: @user, behavior: Behavior.where(name_en: behavior).take).count.should be >= 1
end

Then(/^the database will show a reaction with improvements of "([^"]*)"$/) do |improvements|
  reaction = Reaction.last
  reaction.improvements.should eq improvements
end

Then(/^the database will show a reaction for the user with improvements of "([^"]*)"$/) do |improvements|
  Reaction.where(user: @user, improvements:).count.should be >= 1
end

Then(/^there will be (\d+) reactions from at least (\d+) different narratives recorded$/) do |reaction_count, narrative_diversity|
  Reaction.all.count.should eq reaction_count.to_i
  Reaction.group(:narrative_id).count.count.should >= narrative_diversity.to_i
end

Then(/^there will be (\d+) reactions from (\d+) different narratives recorded$/) do |reaction_count, narrative_diversity|
  Reaction.all.count.should eq reaction_count.to_i
  Reaction.group(:narrative_id).count.count.should eq narrative_diversity.to_i
end

Then(/^there will be (\d+) reactions from (\d+) different scenarios recorded$/) do |reaction_count, scenario_diversity|
  Reaction.all.count.should eq reaction_count.to_i
  Reaction.joins(:narrative).group(:scenario_id).count.count.should eq scenario_diversity.to_i
end

Then(/^no user will have reacted to the same narrative more than once$/) do
  User.all.each do |user|
    reaction_counts = user.reactions.group('narrative_id').count
    reaction_counts.values.each do |val|
      val.should <= 1
    end
  end
end

Then(/^the user successfully completes an experience$/) do
  step 'the user switches to the "Task View" tab'
  step 'the user clicks the link to the experience'
  step 'the user sees the experience instructions page'
  step 'the user presses "Next"'
  14.times do |index|
    step 'the user completes a week'
  end
  step 'the user will see "Overall Group Behavior"'
  step 'the user chooses the "Social loafing" radio button'
  step 'they enter "super comment super" in extant field "Your suggestions:"'
  step 'the user presses hidden "Submit"'
  step 'the database will show a reaction for the user with "Social loafing" as the behavior'
  step 'the database will show a reaction for the user with improvements of "super comment super"'
  step 'the user will see "Your reaction to the experience was recorded"'
  step 'the user will see "100%"'
end

Then(/^all users complete the course successfully$/) do
  # _count = 1
  @course.enrolled_students.each do |user|
    @user = user
    step 'the user logs in'
    step 'the user should see a successful login message'
    step 'the user successfully completes an experience'
    # _count += 1
    step 'the user logs out'
  end
end

Given(/^the user enrolls in a new course$/) do
  @course = School.find(1).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within(range: 100..5000),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be  > 0
  @course.rosters.new(
    user: @user,
    role: Roster.roles[:enrolled_student]
  )
  @course.save
  log @course.errors.full_messages if @course.errors.present?
end

Given(/^the course has an experience$/) do
  @experience = @course.experiences.new(
    name: "#{Faker::Company.industry} Experience",
    start_date: @course.start_date,
    end_date: @course.end_date
  )

  @experience.save
  log @experience.errors.full_messages if @experience.errors.present?
end

Given(/^the user enrolls in the course$/) do
  Roster.create(user: @user, course: @course, role: Roster.roles[:enrolled_student])
end

Then(/^the user is dropped from the course$/) do
  @course.drop_student @user
end

Given('the experience {string} is {int}') do |field, val|
  case field
  when 'lead_time'
    @experience.lead_time = val
  else
    false.should eq true
  end
  @experience.save
  log @experience.errors.full_messages if @experience.errors.present?
end

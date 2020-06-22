# frozen_string_literal: true

require 'forgery'

Then /^the user clicks the link to the experience$/ do
  step 'the user switches to the "Task View" tab'
  find(:xpath, "//div[text()='#{@experience.name}']").click
  # click_link_or_button @experience.name
end 

Then("the {string} button will be disabled") do |button_name|
  elem = find(:xpath,  "//button[contains(.,'#{button_name}')]")
  elem[:disabled].should eq 'true'
end

Then /^the user will see "([^"]*)"$/ do |checkText|
  wait_for_render
  page.should have_content(:all, checkText)
end

Then /^the user presses hidden "([^"]*)"$/ do |linkOrButtonName|
  click_link_or_button linkOrButtonName, visible: :all, disabled: :all
end

Then /^the user presses "([^"]*)"$/ do |linkOrButtonName|
  click_link_or_button linkOrButtonName
end

Then /^they open the drawer for additional comments$/ do
  find(:xpath, "//div[contains(text(),'Click here if you have additional comments for us regarding this narrative.')]").click
end

Then /^they enter "([^"]*)" in extant field "([^"]*)"$/ do |txt, fld|
  label = find( :xpath, "//label[text()='#{fld}']")
  element = find( :xpath, "//input[@id='#{label[:for]}']")
  element.click
  element.send_keys txt
end

Then /^in the field "([^"]*)" they will see "([^"]*)"$/ do |fld, value|
  label = find( :xpath, "//label[text()='#{fld}']")
  panel = all( :xpath, "//input[@id='#{label[:for]}']")
  if panel.size > 0
    panel[0].click
  end
  # click_link_or_button 'Click here if you have additional comments for us regarding this narrative.'
  field_value = panel[ 0 ].value
  expect(field_value).to include value
end

Then /^the user chooses the "([^"]*)" radio button$/ do |choice|
  elem = find(:xpath, "//label[contains(.,\"#{choice}\")]")
  elem.click
end

Then /^the database will show a new week (\d+) "([^"]*)" diagnosis from the user$/ do |week_num, behavior|
  wait_for_render
  diagnosis = Diagnosis.joins(:reaction).where(reactions: { user_id: @user.id }).last
  diagnosis.week.week_num.should eq week_num.to_i
  diagnosis.behavior.name_en.should eq behavior
end

Then /^the latest Diagnosis will show "([^"]*)" in the field "([^"]*)"$/ do |_value, fld|
  diagnosis = Diagnosis.last
  case fld.downcase
  when 'comment'
    diagnosis.comment.should eq fld
  when 'other_text'
    diagnosis.other_name.should eq fld
  end
end

Then /^the user sees the experience instructions page$/ do
  wait_for_render
  step 'the user will see "Instructions for completing"'
end

Then /^the user completes a week$/ do
  reaction = @experience.get_user_reaction @user
  week = reaction.next_week
  # get the current week number

  wait_for_render
  behavior = Behavior.all.to_a.sample
  step_text = 'the user will see "Week ' + week.week_num.to_s + '"'
  step step_text
  step_text = 'the user chooses the "' + behavior.name_en + '" radio button'
  step step_text
  step_text = 'they enter "FUBAR" in extant field "What behavior did you see?"'
  # Only enter behavior name if 'Other' is selected
  step step_text if behavior.name_en == 'Other'
  step_text = 'the user presses "Save and continue"'
  step step_text
  wait_for_render
  step_text = 'the database will show a new week ' + week.week_num.to_s + ' "' + behavior.name_en + '" diagnosis from the user'
  step step_text
end

Then(/^the database will show a reaction with "([^"]*)" as the behavior$/) do |behavior|
  reaction = Reaction.last
  reaction.behavior.name_en.should eq behavior
end

Then(/^the database will show a reaction for the user with "([^"]*)" as the behavior$/) do |behavior|
  Reaction.where(user: @user, behavior: Behavior.where(name_en: behavior).take).count.should be >= 1
end

Then(/^the database will show a reaction with improvements of "([^"]*)"$/) do |improvements|
  reaction = Reaction.last
  reaction.improvements.should eq improvements
end

Then(/^the database will show a reaction for the user with improvements of "([^"]*)"$/) do |improvements|
  Reaction.where(user: @user, improvements: improvements).count.should be >= 1
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

Then /^no user will have reacted to the same narrative more than once$/ do
  User.all.each do |user|
    reaction_counts = user.reactions.group('narrative_id').count
    reaction_counts.values.each do |val|
      val.should <= 1
    end
  end
end

Then /^the user successfully completes an experience$/ do
  step 'the user switches to the "Task View" tab'
  step 'the user clicks the link to the experience'
  step 'the user sees the experience instructions page'
  step 'the user presses "Next"'
  14.times do |_count|
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

Then /^all users complete the course successfully$/ do
  @course.enrolled_students.each do |user|
    @user = user
    step 'the user logs in'
    step 'the user should see a successful login message'
    step 'the user successfully completes an experience'
    step 'the user logs out'
  end
end

Given /^the user enrolls in a new course$/ do
  @course = School.find(1).courses.new(
    name: "#{Forgery::Name.industry} Course",
    number: Forgery::Basic.number,
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
  @course.rosters.new(
    user: @user,
    role: Roster.roles[:enrolled_student]
  )
  @course.save
  puts @course.errors.full_messages if @course.errors.present?
end

Given /^the course has an experience$/ do
  @experience = @course.experiences.new(
    name: Forgery::Name.industry + ' Experience'
  )

  @experience.save
  puts @experience.errors.full_messages if @experience.errors.present?
end

Given /^the user enrolls in the course$/ do
  Roster.create(user: @user, course: @course, role: Roster.roles[:enrolled_student])
end

Then /^the user is dropped from the course$/ do
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
  puts @experience.errors.full_messages if @experience.errors.present?
end

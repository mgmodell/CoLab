# frozen_string_literal: true
Then /^the user clicks the link to the experience$/ do
  first( :link, @experience.name ).click
  #click_link_or_button @experience.name
end

Then /^the user will see "([^"]*)"$/ do |checkText|
  page.should have_content(checkText)
end

Then /^the user presses hidden "([^"]*)"$/ do |linkOrButtonName|
  click_link_or_button linkOrButtonName, visible: :all, disabled: :all
end

Then /^the user presses "([^"]*)"$/ do |linkOrButtonName|
  click_link_or_button linkOrButtonName
end

Then /^they enter "([^"]*)" in extant field "([^"]*)"$/ do |txt, fld|
  page.fill_in(fld, with: txt, visible: :all, disabled: :all)
end

Then /^in the field "([^"]*)" they will see "([^"]*)"$/ do |fld, value|
  field_value = find_field(fld).value
  expect(field_value).to include value
end

Then /^the user chooses the "([^"]*)" radio button$/ do |choice|
  choose(choice)
end

Then /^the database will show a new week (\d+) "([^"]*)" diagnosis from the user$/ do |week_num, behavior|
  diagnosis = Diagnosis.joins(:reaction).where(reactions: { user_id: @user.id }).last
  diagnosis.week.week_num.should eq week_num.to_i
  diagnosis.behavior.name.should eq behavior
end

Then /^the latest Diagnosis will show "([^"]*)" in the field "([^"]*)"$/ do |_value, fld|
  diagnosis = Diagnosis.last
  case fld
  when 'comment'
    diagnosis.comment.should eq fld
  when 'other_text'
    diagnosis.other_name.should eq fld
  end
end

Then /^the user sees the experience instructions page$/ do
  step 'the user will see "Instructions for completing"'
end

Then /^the user completes a week$/ do
  reaction = @experience.get_user_reaction @user
  week = reaction.next_week
  # get the current week number

  behavior = Behavior.all.to_a.sample
  step_text = 'the user will see "Week ' + week.week_num.to_s + '"'
  step step_text
  step_text = 'the user chooses the "' + behavior.name + '" radio button'
  step step_text
  step_text = 'they enter "FUBAR" in extant field "What behavior did you see?"'
  # Only enter behavior name if 'Other' is selected
  step step_text if behavior.name == 'Other'
  step_text = 'the user presses "Save and continue"'
  step step_text
  step_text = 'the database will show a new week ' + week.week_num.to_s + ' "' + behavior.name + '" diagnosis from the user'
  step step_text
end

Then(/^the database will show a reaction with "([^"]*)" as the behavior$/) do |behavior|
  reaction = Reaction.last
  reaction.behavior.name.should eq behavior
end

Then(/^the database will show a reaction for the user with "([^"]*)" as the behavior$/) do |behavior|
  Reaction.where(user: @user, behavior: Behavior.where(name: behavior).take).count.should be >= 1
end

Then(/^the database will show a reaction with improvements of "([^"]*)"$/) do |improvements|
  reaction = Reaction.last
  reaction.improvements.should eq improvements
end

Then(/^the database will show a reaction for the user with improvements of "([^"]*)"$/) do |improvements|
  Reaction.where(user: @user, improvements: improvements).count.should be >= 1
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
  step 'the user clicks the link to the experience'
  step 'the user sees the experience instructions page'
  step 'the user presses "Next"'
  14.times do
    step 'the user completes a week'
  end
  step 'the user will see "Overall Group Behavior"'
  step 'the user chooses the "Social loafing" radio button'
  step 'they enter "super comment super" in extant field "Your suggestions:"'
  step 'the user presses hidden "Submit"'
  step 'the database will show a reaction for the user with "Social loafing" as the behavior'
  step 'the database will show a reaction for the user with improvements of "super comment super"'
  step 'the user will see "Your reaction to the experience was recorded"'
  step 'the user will see "Completed"'
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
  @course = Course.make
  @course.save
  puts @course.errors.full_messages unless @course.errors.blank?
  role = Role.enrolled.take
  r = Roster.create(user: @user, course: @course, role: role)
end

Given /^the course has an experience$/ do
  @experience = Experience.make
  @experience.course = @course
  @experience.save
  puts @experience.errors.full_messages unless @experience.errors.blank?
end

Given /^the user enrolls in the course$/ do
  role = Role.enrolled.take
  r = Roster.create(user: @user, course: @course, role: role)
end

Then /^the user is dropped from the course$/ do
  @course.drop_student @user
end

Then /^the user clicks the link to the experience$/ do
  click_link_or_button @experience.name
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
  diagnosis = Diagnosis.last
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

Then(/^the database will show a reaction with improvements of "([^"]*)"$/) do |improvements|
  reaction = Reaction.last
  reaction.improvements.should eq improvements
end

Then /^the user clicks the link to the experience$/ do
  click_link_or_button @experience.name
end

Then /^the user will see "([^"]*)"$/ do |checkText|
  page.should have_content(checkText)
end

Then /^the user presses "([^"]*)"$/ do |linkOrButtonName|
  click_link_or_button linkOrButtonName
end

Then /^they enter "([^"]*)" in the field "([^"]*)"$/ do |txt, fld|
  page.fill_in( fld, with: txt, :disabled => :all )
  #field = find_field( fld, :disabled => :all )
  #field.value = txt
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
  #get the current week number

  step 'the user will see "Week ' + week.week_num.to_s + '"'
  step 'the user chooses the "Ganging up on the task" radio button'
  step 'the user presses "Save and continue"'
  step 'the database will show a new week ' + week.week_num.to_s + ' "Ganging up on the task" diagnosis from the user'
end

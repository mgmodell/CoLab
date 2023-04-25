Given('the assignment {string} accept {string}') do |does_or_doesnt, sub_type|
  case sub_type.downcase
  when 'text'
    @assignment.text_sub.should eq('does' == does_or_doesnt)
  when 'link'
    @assignment.link_sub.should eq('does' == does_or_doesnt)
  when 'files'
    @assignment.file_sub.should eq('does' == does_or_doesnt)
  else
    true.should be false
  end
end

Given('the init assignment {string} accept {string}') do |does_or_doesnt, sub_type|
  case sub_type.downcase
  when 'text'
    @assignment.text_sub = 'does' == does_or_doesnt
  when 'links'
    @assignment.link_sub = 'does' == does_or_doesnt
  when 'files'
    @assignment.file_sub = 'does' == does_or_doesnt
  else
    true.should be false
  end
  @assignment.save
  log @assignment.errors.full_messages if @assignment.errors.present?
end

Given('the assignment {string} initialized active') do |is_or_isnt|
  @assignment.active = 'is' == is_or_isnt
  @assignment.save
end

Given('the course is shifted {int} {string} into the {string}') do |_int, _string, _string2|
  # Given('the course is shifted {float} {string} into the {string}') do |float, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user opens the {string} task') do |_string|
  find(:xpath, "//td[contains(.,'#{@assignment.name}')]").click
  wait_for_render
end

Then('the user opens the {string} tab') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the shown rubric matches the assignment rubric') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the {string} tab {string} enabled') do |_string, _string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user creates a new submission') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user enters a {string} submission') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the assignment has {int} {string} submission') do |_int, _string|
  # Then('the assignment has {float} {string} submission') do |float, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the {string} db submission data is accurate') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the submission has no group') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the submission is attached to the user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the assignment already has {int} submission from the user') do |_int|
  # Given('the assignment already has {float} submission from the user') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the latest {string} db submission data is accurate') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('today is between the first assignment deadline and close') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('today is after the final deadline') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user withdraws submission {int}') do |_int|
  # Then('the user withdraws submission {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('assignment {int} {string} graded') do |_int, _string|
  # Given('assignment {float} {string} graded') do |float, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user {string} withdraws submission {int}') do |_string, _int|
  # Then('the user {string} withdraws submission {float}') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

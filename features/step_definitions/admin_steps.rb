# frozen_string_literal: true

Given( /^there is a course$/ ) do
  @course = School.find( 1 ).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within( range: 100..5000 ),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name( true ).should_not be_nil
  @course.get_name( true ).length.should be > 0
end

Then( /^the user sets the project to the course's project$/ ) do
  if has_select? 'Source of groups', visible: :all
    page.select( @project.name, from: 'Source of groups', visible: :all )
  else
    find( 'div', id: /bingo_game_project_id/ ).click
    find( 'li', text: @project.name ).click

  end
end

Given('the course is in {string} school') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees {int} students visible') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user {string} see a merge button') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user searches for a user by {string} {string} from {string}') do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user {string} found') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user views the user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees {int} course listed as {string}') do |int, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user {string} see a {string} button') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user closes the user view') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('there is a user who is a researcher') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees anonymized data with no roles') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user an admin') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user clicks the delete button on the user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user clcks the {string} button') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user enters the email address for deleted user {int}') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user is a {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('select user {int} from {string} {string}') do |int, string, string2|
# Given('select user {float} from {string} {string}') do |float, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('switch to user {int}') do |int|
# Then('switch to user {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user enters the email address for user {int} and user {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user searches for user {int} by email') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees {int} {string}') do |int, string|
  pending # Write code here that turns the phrase above into concrete actions
end
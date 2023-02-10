# frozen_string_literal: true

Given('there are {int} {string} rubrics starting with {string}') do |count, is_published, prefix|
  school = School.find(1)
  count.times do |index|
    rubric = school.rubrics.new(
      name: "#{prefix} #{index}",
      description: Faker::GreekPhilosophers.quote,
      passing: 65,
      published: 'published' == is_published,
      user: @user
    )
    rubric.save
    log rubric.errors.full_messages if rubric.errors.present?
  end
end

Given('the user has one rubric named {string}') do |name|
  @rubric = @user.rubrics.new(
    name: name,
    description: Faker::GreekPhilosophers.quote,
    passing: 65,
    school: @user.school
  )
  log @rubric.errors.full_messages if @rubric.errors.present?
end

Then('the assignment rubric is {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('retrieve the {string} rubric') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric {string} is {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees {int} rubrics') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sets criteria {int} {string} to {string}') do |int, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sets criteria {int} level {int} to {string}') do |int, int2, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees the criteria {int} weight is {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user adds a new criteria') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user will see an empty criteria {int}') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sets criteria {int} {string} to to {string}') do |int, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sets the criteria {int} weight to {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('retrieve the {string} rubric from the db') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user is the owner of the rubric') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric version is {int}') do |int|
# Then('the rubric version is {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric {string} field is {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric criteria {int} {string} is {string}') do |int, string, string2|
# Then('the rubric criteria {float} {string} is {string}') do |float, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric criteria {int} level {int} is {string}') do |int, int2, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric criteria {int} weight is {int}') do |int, int2|
# Then('the rubric criteria {int} weight is {float}') do |int, float|
# Then('the rubric criteria {float} weight is {int}') do |float, int|
# Then('the rubric criteria {float} weight is {float}') do |float, float2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric criteria {int} {string} to to {string}') do |int, string, string2|
# Then('the rubric criteria {float} {string} to to {string}') do |float, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric criteria {int} level {int} to {string}') do |int, int2, string|
# Then('the rubric criteria {int} level {float} to {string}') do |int, float, string|
# Then('the rubric criteria {float} level {int} to {string}') do |float, int, string|
# Then('the rubric criteria {float} level {float} to {string}') do |float, float2, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user searches for {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user edits the rubric') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric {string} published') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the {string} rubric is published') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user copies the {string} rubric') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric {string} is {int}') do |string, int|
# Then('the rubric {string} is {float}') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric owner {string} the user') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric parent is {string} {string} {int}') do |string, string2, int|
# Then('the rubric parent is {string} {string} {float}') do |string, string2, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the {string} rubric has {int} criteria') do |string, int|
# Then('the {string} rubric has {float} criteria') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user adds a level to criteria {int}') do |int|
# Then('the user adds a level to criteria {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('remember the data for criteria {int}') do |int|
# Then('remember the data for criteria {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees that criteria {int} matches the remembered criteria') do |int|
# Then('the user sees that criteria {float} matches the remembered criteria') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user deletes criteria {int}') do |int|
# Then('the user delete's criteria {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('criteria {int} matches the remembered criteria') do |int|
# Then('criteria {float} matches the remembered criteria') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user moves criteria {int} up {int}') do |int, int2|
# Then('the user moves criteria {int} up {float}') do |int, float|
# Then('the user moves criteria {float} up {int}') do |float, int|
# Then('the user moves criteria {float} up {float}') do |float, float2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user deletes the rubric') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user can not {string} the rubric') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('there exists a rubric published by another user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the existing rubric is attached to this assignment') do
  pending # Write code here that turns the phrase above into concrete actions
end
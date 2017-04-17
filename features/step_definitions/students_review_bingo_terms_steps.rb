Given /^the user is any student in the course$/  do
  @user = @course.rosters.enrolled.sample.user
end

Then /^the user clicks the link to the concept list$/  do
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the concept list should match the list$/  do
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the user should see (\d+) concepts$/  do |concept_count|
  pending # Write code here that turns the phrase above into concrete actions
end


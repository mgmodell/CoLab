Given /^the Bingo! is group\-enabled with the project and a (\d+) percent group discount$/  do |group_discount|
  @bingo.group_option = true
  @bingo.project = @project
  @bingo.group_discount = group_discount
end

Then /^the user "([^"]*)" see collaboration was requested$/  do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

When /^the user requests collaboration$/  do
  pending # Write code here that turns the phrase above into concrete actions
end

When /^group user (\d+) logs in$/  do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the user should see they're waiting on a collaboration response$/  do
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the user "([^"]*)" the collaboration request$/  do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the user "([^"]*)" see collaboration request button$/  do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

When /^the user populates (\d+) of the "([^"]*)" entries prepped for group$/  do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

When /^the user populates (\d+) additional "([^"]*)" entries$/  do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

When /^the user changes the first (\d+) "([^"]*)" entries$/  do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end


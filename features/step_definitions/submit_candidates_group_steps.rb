Given /^the Bingo! is group\-enabled with the project and a (\d+) percent group discount$/  do |group_discount|
  @bingo.group_option = true
  @bingo.project = @project
  @bingo.group_discount = group_discount
end

Then /^the user "([^"]*)" see collaboration was requested$/  do |collaboration_pending|
  case collaboration_pending.downcase
  when 'should'
    page.should have_content "Your group has asked you to collaborate: "
  when 'should not'
    page.should_not have_content "Your group has asked you to collaborate: "
  else
    puts "We didn't test anything there: " + collaboration_pending
  end
end

When /^the user requests collaboration$/  do
  click_link_or_button "Invite your group to help?"
end

When /^group user (\d+) logs in$/  do |user_count|
  @user = @group.users[ user_count.to_i - 1 ]
  step "the user logs in"
end

Then /^the user should see they're waiting on a collaboration response$/  do
  case collaboration_pending.downcase
  when 'should'
    page.should have_content "Awaiting group response to collaboration request"
  when 'should not'
    page.should_not have_content "Awaiting group response to collaboration request"
  else
    puts "We didn't test anything there: " + collaboration_pending
  end
end

Then /^the user "([^"]*)" the collaboration request$/  do |accept_or_decline|
  case accept_or_decline.downcase
  when 'should'
    click_link_or_button "Collaborate"
  when 'should not'
    click_link_or_button "Work on my own"
  else
    puts "We didn't test anything there: " + accept_or_decline
  end
end

Then /^the user "([^"]*)" see collaboration request button$/  do |button_present|
  case button_present.downcase
  when 'should'
    page.should have_content "Invite your group to help?"
  when 'should not'
    page.should_not have_content "Invite your group to help?"
  else
    puts "We didn't test anything there: " + button_present
  end
end

When /^the user populates (\d+) additional "([^"]*)" entries$/  do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

When /^the user changes the first (\d+) "([^"]*)" entries$/  do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the candidate lists have been merged$/ do
  pending # Write code here that turns the phrase above into concrete actions
end

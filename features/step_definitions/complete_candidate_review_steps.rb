Given /^the users "([^"]*)" prep as "([^"]*)"$/  do |completion_level, group_or_individual|
  temp_user = @user
  @users.each do |user|
    @user = user
    step "the user logs in"
    step "the user logs out"
  end

  @user = temp_user

end

Then /^the user sees (\d+) candidate items for review$/  do |candidate_count|
  page.all(:xpath, "//select[contains(@id, 'candidate_feedback')]").
                count.should eq candidate_count.to_i
  page.all(:xpath, "//select[contains(@id, 'concept')]").
                count.should eq candidate_count.to_i
end

Given /^the user assigns "([^"]*)" to all candidates$/  do |feedback_type|
  pending # Write code here that turns the phrase above into concrete actions
end

Given /^the user checks "([^"]*)"$/  do |arg1|
  check( "Review complete" )
end


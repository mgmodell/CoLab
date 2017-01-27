Then(/^the user should see "([^"]*)"$/) do |page_text|
  page.should_have_content page_text
end

Given(/^the user timezone is "([^"]*)"$/) do |timezone|
  @user.timezone = timezone
  @user.save
end

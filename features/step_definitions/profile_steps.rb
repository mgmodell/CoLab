# frozen_string_literal: true

Then /^user opens their profile$/ do
  click_link_or_button('Profile')
  page.should have_content('Edit your profile')
  page.should have_content('Tell us about yourself, ' + @user.first_name)
  @user.emails.each do |email|
    page.should have_content(email.email)
  end
end

Then /^the user sees the experience in the history$/ do
  page.should have_content(@experience.get_name(false))
end

Then /^user sees the Bingo! in the history$/ do
  page.should have_content(@bingo.get_name(false))
end

Then /^user sees the assessed project in the history$/ do
  page.should have_content(@project.get_name(false))
end

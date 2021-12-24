# frozen_string_literal: true

Then(/^user opens their profile$/) do
  wait_for_render
  find(:xpath, '//*[@id="main-menu-button"]').click
  find(:xpath, '//*[@id="profile-menu-item"]').click
  page.should have_content('Edit your profile')
  text = "Tell us about yourself, #{@user.first_name} (optional)"
  all(:xpath, "//div[contains(.,'#{text}')]").size.should be > 3
  # page.should have_content('Tell us about yourself, ' + @user.first_name)
  find(:xpath, "//div[text()='Email Settings']").click
  @user.emails.each do |email|
    page.should have_content(email.email)
  end
end

Then(/^the user sees the experience in the history$/) do
  find(:xpath, "//button[contains(.,'History')]").click
  page.should have_content(@experience.get_name(false))
end

Then(/^user sees the Bingo! in the history$/) do
  find(:xpath, "//button[contains(.,'History')]").click
  page.should have_content(@bingo.get_name(false))
end

Then(/^user sees the assessed project in the history$/) do
  find(:xpath, "//button[contains(.,'History')]").click
  wait_for_render
  page.should have_content(@project.get_name(false))
end

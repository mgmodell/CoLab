Then /^the user will see the task listing page$/ do
  page.should have_content 'Your Tasks'
end

Then /^the user will see a consent request$/ do
  page.should have_content 'May we user your data for research?'
end

When /^the user "(.*?)" provide consent$/ do |does_or_does_not|
  consent = does_or_does_not == 'does'
  check('consent_log[accepted]') if consent
  click_button 'Respond to Consent Form'
end

Then /^the user will see a request for demographics$/ do
  page.should have_content 'Edit your profile'
end

Given /^a user has signed up$/ do
  @user = User.make
  @user.confirm
  @user.save
end

When /^the user "(.*?)" fill in demographics data$/ do |does_or_does_not|
  give_demographics = does_or_does_not == 'does'
  if give_demographics
    page.select('Male', from: 'user_gender_id')
    page.select('18-20', from: 'user_age_range_id')
    page.select('Belize', from: 'user_country')
    # Current password has been removed from this page.
    # page.fill_in('user_current_password', with: 'password')
  end
  click_button 'my profile'
end

Given /^(\d+) users$/ do |user_count|
  @users = []
  user_count.to_i.times do
    u = User.make
    @users << u
  end
end

Given /^a course$/ do
  @course = Course.make
end

Then /^the users are added to the course by email address$/ do
  email_list = ''
  @users.each do |user|
    email_list += user.email + ', '
  end
  @course.add_students_by_email email_list
end

Then /^the course has (\d+) "([^"]*)" users$/ do |user_count, user_status|
  @course.rosters.joins(:role).where(roles: { name: user_status }).count.should eq user_count.to_i
end

Then /^(\d+) emails will have been sent$/  do |email_count|
  ActionMailer::Base.deliveries.count.should eq email_count.to_i
end

Given /^the users are confirmed$/ do
  @users.each(&:confirm)
end

Then /^the user "([^"]*)" enrollment in the course$/ do |_arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

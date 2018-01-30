# frozen_string_literal: true
require 'forgery'

Then /^the user will see the task listing page$/ do
  page.should have_content 'Your Tasks'
end

Then /^the user will see a consent request$/ do
  page.should have_content 'May we use your data for research?'
end

When /^the user "(.*?)" provide consent$/ do |does_or_does_not|
  consent = does_or_does_not == 'does'
  check('consent_log[accepted]') if consent
  click_button 'Record my response to this Consent Form'
end

Then /^the user will see a request for demographics$/ do
  page.should have_content 'Edit your profile'
end

Given /^a user has signed up$/ do
  @user = User.new(
    first_name: Forgery::Name.first_name,
    last_name: Forgery::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    email: Forgery::Internet.email_address,
    timezone: 'UTC',
    theme_id: 1
  )
  @user.confirm
  @user.save
  puts @user.errors.full_messages unless @user.errors.blank?
  @user.name(true).should_not be ', '
  @user.name(true).length.should be > 2
end

When /^the user "(.*?)" fill in demographics data$/ do |does_or_does_not|
  give_demographics = does_or_does_not == 'does'
  if give_demographics
    page.select('Male', from: 'user_gender_id')
    page.select('Education', from: 'user_cip_code_id')
    page.select('Belize', from: 'country')
    page.select('Avestan', from: 'user_primary_language_id')

    new_date = Date.parse('10-05-1976')
    page.find('#user_date_of_birth').set(new_date)
    new_date = Date.parse('10-09-2016')
    page.find('#user_date_of_birth').set(new_date)
  end
  click_button 'my profile'
end

Given /^(\d+) users$/ do |user_count|
  @users = []
  user_count.to_i.times do
    u = User.new(
      first_name: Forgery::Name.first_name,
      last_name: Forgery::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Forgery::Internet.email_address,
      timezone: 'UTC',
      theme_id: 1
    )
    u.save
    @users << u
  end
end

Given /^a course$/ do
  @course = School.find( 1 ).courses.new(
    name: "#{Forgery::Name.industry} Course",
    number: Forgery::Basic.number,
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
end

Then /^the users are added to the course by email address$/ do
  email_list = ''
  @users.each do |user|
    email_list += user.email + ', '
  end
  @course.add_students_by_email email_list
end

Then /^the users are added to the course as instructors by email address$/ do
  email_list = ''
  @users.each do |user|
    email_list += user.email + ', '
  end
  @course.add_instructors_by_email email_list
end

Then /^the course has (\d+) "([^"]*)" users$/ do |user_count, user_status|
  status = 0
  case user_status.downcase
  when 'invited student'
    status = Roster.roles[:invited_student]
  when 'instructor'
    status = Roster.roles[:instructor]
  when 'enrolled student'
    status = Roster.roles[:enrolled_student]
  when 'declined student'
    status = Roster.roles[:declined_student]
  end
  @course.rosters.where(role: status).count.should eq user_count.to_i
end

Then /^(\d+) emails will have been sent$/  do |email_count|
  ActionMailer::Base.deliveries.count.should eq email_count.to_i
end

Given /^the users are confirmed$/ do
  @users.each(&:confirm)
end

Then /^the user "([^"]*)" enrollment in the course$/ do |accept|
  if accept == 'accepts'
    click_link_or_button 'Accept'
  else
    click_link_or_button 'Decline'
  end
end

Then /^the user sees (\d+) invitation$/ do |invitation_count|
  page.should have_content 'confirm that you are actually enrolled in'
  if invitation_count.to_i == 1
    page.should have_content 'the course listed below'
  else
    page.should have_content invitation_count.to_s + ' courses listed below'
  end
end

Then /^the user does not see a task listing$/ do
  page.should have_no_content 'Your Tasks'
end

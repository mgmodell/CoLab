# frozen_string_literal: true

require 'forgery'
require 'chronic'

Given /^there is a course with an assessed project$/ do
  @course = School.find(1).courses.new(
    name: "#{Forgery::Name.industry} Course",
    number: Forgery::Basic.number,
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  puts @course.errors.full_messages unless @course.errors.blank?
  @project = @course.projects.new(
    name: "#{Forgery::Name.industry} Project",
    start_dow: 1,
    end_dow: 2,
    style: Style.find(1)
  )

  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?

  # Check that the anonymous stuff got built
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
  @project.get_name(true).should_not be_nil
  @project.get_name(true).length.should be > 0
end

Given /^the project started "(.*?)" and ends "(.*?)", opened "(.*?)" and closes "(.*?)"$/ do |start_date, end_date, start_dow, end_dow|
  @project.start_date = Chronic.parse(start_date)
  @project.end_date = Chronic.parse(end_date)
  @project.start_dow = Chronic.parse(start_dow).wday
  @project.end_dow = Chronic.parse(end_dow).wday

  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

Given /^the project has a group with (\d+) confirmed users$/ do |user_count|
  @group = @project.groups.new(
    name: "#{Forgery::Basic.text} Group"
  )
  @users = []
  user_count.to_i.times do
    user = @group.users.new(
      first_name: Forgery::Name.first_name,
      last_name: Forgery::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Forgery::Internet.email_address,
      timezone: 'UTC',
      theme_id: 1
    )
    user.skip_confirmation!
    @users << user
    r = user.rosters.new(
      course: @course,
      role: Roster.roles[:enrolled_student]
    )
    user.save
    puts user.errors.full_messages unless user.errors.blank?
    r.save
    puts r.errors.full_messages unless r.errors.blank?
  end
  @group.save
  @group.get_name(true).should_not be_nil
  @group.get_name(true).length.should be > 0
  puts @group.errors.full_messages unless @group.errors.blank?
end

Given /^the project has been deactivated$/ do
  @project.active = false
  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

Given /^the project has been activated$/ do
  @project.active = true
  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

Then /^the user should see a successful login message$/ do
  page.should have_content 'Signed in successfully.'
end

Then /^user should see (\d+) open task$/ do |open_project_count|
  case open_project_count.to_i
  when 0
    page.should have_content  'You do not currently have any tasks due.'
  when 1
    page.should have_content  'one task at the moment'
  else
    page.should have_content ( open_project_count.to_s + ' tasks today')
  end
end

Then /^the user will see the main index page$/ do
  page.should have_content 'Your Projects'
end

Given /^the user "(.*?)" had demographics requested$/ do |with_demographics|
  demographics_requested = with_demographics == 'has'
  @user.welcomed = demographics_requested
  @user.save!
  puts @user.errors.full_messages unless @user.errors.blank?
end

When /^the user logs in$/ do
  visit '/'
  fill_in 'user[email]', with: @user.email
  fill_in 'user[password]', with: 'password'

  click_link_or_button 'Log in'
end

# frozen_string_literal: true
require 'chronic'

Given /^there is a course with an assessed project$/ do
  @course = Course.make
  @course.save
  @course.get_name( true ).should_not be_nil
  @course.get_name( true ).length.should be > 0
  puts @course.errors.full_messages unless @course.errors.blank?
  @project = Project.make
  @project.style = Style.find(1)
  @project.course = @course
  @project.save
  @project.get_name( true ).should_not be_nil
  @project.get_name( true ).length.should be > 0
  puts @project.errors.full_messages unless @project.errors.blank?
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
  @group = Group.make
  @users = []
  role = Role.enrolled.take
  user_count.to_i.times do
    user = User.make
    user.skip_confirmation!
    @group.users << user
    @users << user
    r = Roster.new
    r.user = user
    r.course = @course
    r.role = role
    r.save
    puts r.errors.full_messages unless r.errors.blank?
  end
  @project.groups << @group
  @project.save
  @project.get_name( true ).should_not be_nil
  @project.get_name( true ).length.should be > 0
  puts @project.errors.full_messages unless @project.errors.blank?
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
    page.should have_content ( open_project_count + ' tasks today')
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

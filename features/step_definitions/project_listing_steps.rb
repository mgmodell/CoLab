# frozen_string_literal: true

require 'faker'
require 'chronic'

Given(/^there is a course with an assessed project$/) do
  @course = School.find(1).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within(range: 100..5000),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  log @course.errors.full_messages if @course.errors.present?
  @project = @course.projects.new(
    name: "#{Faker::Company.industry} Project",
    start_dow: 1,
    end_dow: 2,
    style: Style.find(1)
  )

  @project.save
  log @project.errors.full_messages if @project.errors.present?

  # Check that the anonymous stuff got built
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
  @project.get_name(true).should_not be_nil
  @project.get_name(true).length.should be > 0
end

Given(/^the project started "(.*?)" and ends "(.*?)", opened "(.*?)" and closes "(.*?)"$/) do |start_date, end_date, start_dow, end_dow|
  @project.start_date = Chronic.parse(start_date)
  @project.end_date = Chronic.parse(end_date)
  @project.start_dow = Chronic.parse(start_dow).wday
  @project.end_dow = Chronic.parse(end_dow).wday

  @project.save
  log @project.errors.full_messages if @project.errors.present?
end

Given(/^the project has a group with (\d+) confirmed users$/) do |user_count|
  @group = @project.groups.new(
    name: "#{Faker::Hobby.activity} Group"
  )
  @users = []
  user_count.to_i.times do
    user = @group.users.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Faker::Internet.email,
      timezone: 'UTC',
      school: School.find(1),
      theme_id: 1
    )
    user.skip_confirmation!
    @users << user
    r = user.rosters.new(
      course: @course,
      role: Roster.roles[:enrolled_student]
    )
    user.save
    log user.errors.full_messages if user.errors.present?
    r.save
    log r.errors.full_messages if r.errors.present?
  end
  @group.save
  @group.get_name(true).should_not be_nil
  @group.get_name(true).length.should be > 0
  log @group.errors.full_messages if @group.errors.present?
end

Given(/^the project has been deactivated$/) do
  @project.active = false
  @project.save
  log @project.errors.full_messages if @project.errors.present?
end

Given(/^the project has been activated$/) do
  @project.active = true
  @project.save
  log @project.errors.full_messages if @project.errors.present?
end

Then(/^the user should see a successful login message$/) do
  page.should have_content 'Signed in successfully.'
end

Then(/^user should see (\d+) open task$/) do |open_project_count|
  case open_project_count.to_i
  when 0
    page.should have_content  'You do not currently have any tasks due.'
  when 1
    page.should have_content  'one task at the moment'
  else
    page.should have_content(open_project_count.to_s + ' tasks today')
  end
end

Then(/^the user will see the main index page$/) do
  page.should have_content 'Your Projects'
end

Given(/^the user "(.*?)" had demographics requested$/) do |with_demographics|
  demographics_requested = with_demographics == 'has'
  @user.welcomed = demographics_requested
  @user.save!
  log @user.errors.full_messages if @user.errors.present?
end

When(/^the user logs in$/) do
  visit '/'
  fill_in 'email', with: @user.email
  fill_in 'password', with: 'password'

  click_link_or_button 'Log in'
  wait_for_render
end

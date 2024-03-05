# frozen_string_literal: true

require 'chronic'
require 'faker'

Given(/^there is a course with an experience$/) do
  @course = School.find(1).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within(range: 100..6000),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save!
  @experience = @course.experiences.new(
    name: "#{Faker::Company.industry} Experience",
    start_date: DateTime.yesterday,
    end_date: DateTime.tomorrow
  )
  @experience.save!
  log @experience.errors.full_messages if @experience.errors.present?

  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be  > 0
  @experience.get_name(true).should_not be_nil
  @experience.get_name(true).length.should be  > 0
end

Given(/^the experience "([^"]*)" been activated$/) do |has_or_has_not|
  @experience.active = 'has' == has_or_has_not
  @experience.save!
  log @experience.errors.full_messages if @experience.errors.present?
end

Given(/^the course has (\d+) confirmed users$/) do |user_count|
  @users = []
  user_count.to_i.times do
    user = User.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Faker::Internet.email,
      timezone: 'UTC',
      school: School.find(1),
      welcomed: true,
      theme_id: 1
    )
    user.skip_confirmation!
    user.save!
    log user.errors.full_messages unless user.errors.empty?
    @users << user
    r = user.rosters.new(
      course: @course,
      role: Roster.roles[:enrolled_student]
    )
    r.save!
    log r.errors.full_messages if r.errors.present?
  end
end

Given(/^the experience started "([^"]*)" and ends "([^"]*)"$/) do |start_date, end_date|
  course_tz = ActiveSupport::TimeZone.new(@experience.course.timezone)
  d = Chronic.parse(start_date)
  @experience.reload
  @experience.start_date = course_tz.local(d.year, d.month, d.day)
  d = Chronic.parse(end_date)
  @experience.end_date = course_tz.local(d.year, d.month, d.day)
  @experience.save!
  log @experience.errors.full_messages if @experience.errors.present?
end

Given(/^the users "(.*?)" had demographics requested$/) do |with_demographics|
  demographics_requested = 'have' == with_demographics
  @users.each do |u|
    u.welcomed = demographics_requested
    u.save!
    log u.errors.full_messages if u.errors.present?
  end
end

Given(/^the user is "(.*?)" user$/) do |which|
  case which.downcase
  when 'a random'
    tmp_id = @user&.id 
    @user = @users.sample
    @user = @users.sample while tmp_id == @user.id && @users.size > 1
  when 'the first' then @user = @users.first
  when 'the second' then @user = @users[1]
  when 'the third' then @user = @users[2]
  when 'the last' then @user = @users.last
  else
    log "There's no '#{which}' user"
    pending
  end
end

Given(/^the course has an assessed project$/) do
  yesterday = DateTime.yesterday
  tomorrow = DateTime.tomorrow

  @project = @course.projects.new(
    name: "#{Faker::Company.industry} Project",
    start_dow: 1,
    end_dow: 2,
    start_date: yesterday,
    end_date: tomorrow,
    style: Style.find(2)
  )
  @project.save!
  if @project.persisted?
    @project.get_name(true).should_not be_nil
    @project.get_name(true).length.should be  > 0
  end
  log @project.errors.full_messages if @project.errors.present?
end

Given(/^the user is in a group on the project$/) do
  @group = @project.groups.new(
    name: "#{Faker::Hacker.noun} #{Faker::Team.creature}"
  )
  @project.active = false

  3.times do
    u = @group.users.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Faker::Internet.email,
      timezone: 'UTC',
      school: School.find(1),
      theme_id: 1
    )
    u.skip_confirmation!
    u.save!
    log u.errors.full_messages if u.errors.present?
    r = u.rosters.new(
      course: @project.course,
      role: Roster.roles[:enrolled_student]
    )
    u.save!
    r.save!
    log r.errors.full_messages if r.errors.present?
  end
  @group.users << @user
  @group.save!
  @group.get_name(true).should_not be_nil
  @group.get_name(true).length.should be  > 0
  log @group.errors.full_messages if @group.errors.present?
  @project.active = false
  @project.save!
  log @project.errors.full_messages if @project.errors.present?
end

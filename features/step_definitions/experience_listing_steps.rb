# frozen_string_literal: true

require 'chronic'
require 'forgery'

Given(/^there is a course with an experience$/) do
  @course = School.find(1).courses.new(
    name: "#{Forgery::Name.industry} Course",
    number: Forgery::Basic.number,
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @experience = @course.experiences.new(
    name: "#{Forgery::Name.industry} Experience",
    start_date: DateTime.yesterday,
    end_date: DateTime.tomorrow
  )
  @experience.save
  puts @experience.errors.full_messages unless @experience.errors.blank?

  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
  @experience.get_name(true).should_not be_nil
  @experience.get_name(true).length.should be > 0
end

Given(/^the experience "([^"]*)" been activated$/) do |has_or_has_not|
  @experience.active = has_or_has_not == 'has'
  @experience.save
  puts @experience.errors.full_messages unless @experience.errors.blank?
end

Given(/^the course has (\d+) confirmed users$/) do |user_count|
  @users = []
  user_count.to_i.times do
    user = User.new(
      first_name: Forgery::Name.first_name,
      last_name: Forgery::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Forgery::Internet.email_address,
      timezone: 'UTC',
      school: School.find(1),
      theme_id: 1
    )
    user.skip_confirmation!
    user.save
    puts user.errors.full_messages unless user.errors.empty?
    @users << user
    r = user.rosters.new(
      course: @course,
      role: Roster.roles[:enrolled_student]
    )
    r.save
    puts r.errors.full_messages unless r.errors.blank?
  end
end

Given /^the experience started "([^"]*)" and ends "([^"]*)"$/ do |start_date, end_date|
  course_tz = ActiveSupport::TimeZone.new(@experience.course.timezone)
  d = Chronic.parse(start_date)
  @experience.start_date = course_tz.local(d.year, d.month, d.day)
  d = Chronic.parse(end_date)
  @experience.end_date = course_tz.local(d.year, d.month, d.day)
  @experience.save
  puts @experience.errors.full_messages unless @experience.errors.blank?
end

Given /^the users "(.*?)" had demographics requested$/ do |with_demographics|
  demographics_requested = with_demographics == 'have'
  @users.each do |u|
    u.welcomed = demographics_requested
    u.save!
    puts u.errors.full_messages unless u.errors.blank?
  end
end

Given /^the user is "(.*?)" user$/ do |which|
  case which.downcase
  when 'a random' then @user = @users.sample
  when 'the first' then @user = @users.first
  when 'the second' then @user = @users[1]
  when 'the third' then @user = @users[2]
  when 'the last' then @user = @users.last
  else
    puts "There's no '#{which}' user"
    pending
  end
end

Given /^the course has an assessed project$/ do
  @project = @course.projects.new(
    name: "#{Forgery::Name.industry} Project",
    start_dow: 1,
    end_dow: 2,
    start_date: DateTime.yesterday,
    end_date: DateTime.tomorrow,
    style: Style.find(1)
  )
  @project.save
  if @project.persisted?
    @project.get_name(true).should_not be_nil
    @project.get_name(true).length.should be > 0
  end
  puts @project.errors.full_messages unless @project.errors.blank?
end

Given /^the user is in a group on the project$/ do
  @group = @project.groups.new(
    name: "#{Forgery::Basic.text} Group"
  )
  @project.active = false

  3.times do
    u = @group.users.new(
      first_name: Forgery::Name.first_name,
      last_name: Forgery::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Forgery::Internet.email_address,
      timezone: 'UTC',
      school: School.find(1),
      theme_id: 1
    )
    u.skip_confirmation!
    u.save
    puts u.errors.full_messages unless u.errors.blank?
    r = u.rosters.new(
      course: @project.course,
      role: Roster.roles[:enrolled_student]
    )
    u.save
    r.save
    puts r.errors.full_messages unless r.errors.blank?
  end
  @group.users << @user
  @group.save
  @group.get_name(true).should_not be_nil
  @group.get_name(true).length.should be > 0
  puts @group.errors.full_messages unless @group.errors.blank?
  @project.active = false
  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

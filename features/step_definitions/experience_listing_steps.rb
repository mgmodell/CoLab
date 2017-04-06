# frozen_string_literal: true
require 'chronic'

Given(/^there is a course with an experience$/) do
  @course = Course.make
  @course.save
  @experience = Experience.make
  @experience.course = @course
  @experience.save
end

Given(/^the experience "([^"]*)" been activated$/) do |has_or_has_not|
  @experience.active = has_or_has_not == 'has'
  @experience.save
end

Given(/^the course has (\d+) confirmed users$/) do |user_count|
  role = Role.enrolled.take
  @users = []
  user_count.to_i.times do
    user = User.make
    user.skip_confirmation!
    @users << user
    r = Roster.new
    r.user = user
    r.course = @course
    r.role = role
    r.save
  end
end

Given /^the experience started "([^"]*)" and ends "([^"]*)"$/ do |start_date, end_date|
  @experience.start_date = Chronic.parse(start_date)
  @experience.end_date = Chronic.parse(end_date)
  @experience.save
end

Given /^the users "(.*?)" had demographics requested$/ do |with_demographics|
  demographics_requested = with_demographics == 'have'
  @users.each do |u|
    u.welcomed = demographics_requested
    u.save!
  end
end

Given /^the user is "(.*?)" user$/ do |which|
  case which
  when 'a random' then @user = @users.sample
  when 'the first' then @user = @users.first
  when 'the last' then @user = @users.last
  end
end

Given /^the course has an assessed project$/ do
  @project = Project.make
  @project.style = Style.find(1)
  @project.course = @course
  @project.save
end

Given /^the user is in a group on the project$/ do
  @group = Group.make
  @project.active = false

  role = Role.enrolled.take
  @project.groups << @group
  3.times do
    u = User.make
    u.skip_confirmation!
    r = Roster.new
    r.user = u
    r.course = @project.course
    r.role = role
    r.save
    @group.users << u
  end
  @group.users << @user
  @group.save
  @group.save
  @project.active = false
  @project.save
end

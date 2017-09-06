# frozen_string_literal: true
require 'chronic'

Given(/^there is a course with an experience$/) do
  @course = Course.make
  @course.save
  @course.get_name( true ).should_not be_nil
  @course.get_name( true ).length.should be > 0
  puts @course.errors.full_messages unless @course.errors.blank?
  @experience = Experience.make
  @experience.course = @course
  @experience.save
  @experience.get_name( true ).should_not be_nil
  @experience.get_name( true ).length.should be > 0
  puts @experience.errors.full_messages unless @experience.errors.blank?
end

Given(/^the experience "([^"]*)" been activated$/) do |has_or_has_not|
  @experience.active = has_or_has_not == 'has'
  @experience.save
  puts @experience.errors.full_messages unless @experience.errors.blank?
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
    puts r.errors.full_messages unless r.errors.blank?
  end
end

Given /^the experience started "([^"]*)" and ends "([^"]*)"$/ do |start_date, end_date|
  @experience.start_date = Chronic.parse(start_date)
  @experience.end_date = Chronic.parse(end_date)
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
  case which
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
  @project = Project.make
  @project.style = Style.find(1)
  @project.course = @course
  @project.save
  if @project.persisted?
    @project.get_name( true ).should_not be_nil
    @project.get_name( true ).length.should be > 0
  end
  puts @project.errors.full_messages unless @project.errors.blank?
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
    puts r.errors.full_messages unless r.errors.blank?
    @group.users << u
  end
  @group.users << @user
  @group.save
  @group.get_name( true ).should_not be_nil
  @group.get_name( true ).length.should be > 0
  puts @group.errors.full_messages unless @group.errors.blank?
  @project.active = false
  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

require 'chronic'

Given(/^there is a course with an experience$/) do
  @course = Course.make
  @course.save
  @experience = Experience.make
  @experience.course = @course
  @experience.save
end

Given(/^the experience has been activated$/) do
  @experience.active = true
  @experience.save
end

Given(/^the course has (\d+) confirmed users$/) do |user_count|
  role = Role.where( name: "Enrolled Student" ).take
  @users = [ ]
  user_count.to_i.times do
    user = User.make
    @users << user
    r = Roster.new
    r.user = user
    r.course = @course
    r.role = role
    r.save
  end
end

Given(/^the experience started "([^"]*)" and ends "([^"]*)"$/) do |start_date, end_date|
  @experience.start_date = Chronic.parse( start_date )
  @experience.end_date = Chronic.parse( end_date )
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
    when "a random" then @user = @users.sample
    when "the first" then @user = @users.sample
    when "the last" then @user = @users.sample
  end
end

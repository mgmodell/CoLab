# frozen_string_literal: true
require 'forgery'

Given /^the email queue is empty$/ do
  ActionMailer::Base.deliveries = []
  ActionMailer::Base.deliveries.count.should eq 0
end

When /^the system emails stragglers$/ do
  AdministrativeMailer.send_reminder_emails
end

When /^the system emails instructor reports$/ do
  AdministrativeMailer.inform_instructors
end

Then /^an email will be sent to each member of the group$/ do
  wt = @user.waiting_student_tasks
  g = wt[0].group_for_user(@user)
  group_count = g.users.count
  ActionMailer::Base.deliveries.count.should eq group_count
end

Then /^an email will be sent to each member of the group but one$/ do
  ows = @user.waiting_student_tasks
  g = ows[0].group_for_user(@user)
  group_count_minus_one = g.users.count - 1
  ActionMailer::Base.deliveries.count.should eq group_count_minus_one
end

Then /^no emails will be sent$/ do
  ActionMailer::Base.deliveries.count.should eq 0
end

Then /^(\d+) emails will be sent$/ do |email_count|
  ActionMailer::Base.deliveries.count.should eq email_count.to_i
end

Then /^show the email queue$/ do
  ActionMailer::Base.deliveries.each do |mail|
    puts mail
  end
end

Given /^the user is in a group on the project with (\d+) other users$/ do |user_count|
  @group = Group.new(
    name: "#{Forgery::Basic.text} Group",
  )
  r = Roster.new
  r.user = @user
  r.course = @course
  r.role = Roster.roles[:enrolled_student]
  r.save
  puts r.errors.full_messages unless r.errors.blank?
  @group.users << @user
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
    user.save
    user.rosters.new(
      course: @course,
      role: Roster.roles[:enrolled_student]
    )
    r.save
    puts r.errors.full_messages unless r.errors.blank?
  end
  @project.groups << @group
  @project.save
  puts @project.errors.full_messages unless @project.errors.blank?
end

Then /^the members of "([^"]*)" group go to other groups$/ do |ordinal|
  if @project.groups.count > 1
    case ordinal.downcase
    when 'a random' then to_disperse = @project.groups.sample
    when 'the first' then to_disperse = @project.groups.first
    when 'the last' then to_disperse = @project.groups.last
    end

    groups = @project.groups
    to_disperse.users.each do |user|
      group = groups.first
      unless group == to_disperse
        user = to_disperse.users.first
        group.users << user
        to_disperse.users.delete user
      end
      groups.rotate
    end
    groups.each(&:save)
  end
end

# frozen_string_literal: true
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

Given /^the user is in a group on the project with (\d+) other users$/ do |user_count|
  @group = Group.make
  role = Role.enrolled.take
  r = Roster.new
  r.user = @user
  r.course = @course
  r.role = role
  r.save
  puts r.errors.full_messages unless r.errors.nil?
  @group.users << @user
  user_count.to_i.times do
    user = User.make
    user.skip_confirmation!
    @group.users << user
    r = Roster.new
    r.user = user
    r.course = @course
    r.role = role
    r.save
    puts r.errors.full_messages unless r.errors.nil?
  end
  @project.groups << @group
  @project.save
  puts @project.errors.full_messages unless @project.errors.nil?
end

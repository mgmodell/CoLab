require 'chronic'
# frozen_string_literal: true
Then /^the user "([^"]*)" see an Admin button$/ do |admin|
  if admin == 'does'
    page.should have_content('Administration')
  else
    page.should_not have_content('Administration')
  end
end

Given /^the user is an admin$/ do
  @user.admin = true
  @user.save
  puts @user.errors.full_messages unless @user.errors.blank?
end

Then /^the user clicks the Admin button$/ do
  click_link_or_button 'Administration'
end

Then /^the user sees (\d+) course$/ do |course_count|
  page.all('tr').count == course_count.to_i + 1
end

Given /^the user is the instructor for the course$/ do
  @course.set_user_role @user, 'Instructor'
end

Then /^the user opens the course$/ do
  click_link_or_button 'Show'
end

Then /^the user clicks "([^"]*)"$/ do |link_or_button|
  click_link_or_button link_or_button
end

Then /^the user sets the hidden tab field "([^"]*)" to "([^"]*)"$/ do |field, value|
  find(:xpath, "//input[@id='" + field + "']").set value
  # page.fill_in( field, with: value )
end

Then /^the user sets the "([^"]*)" field to "([^"]*)"$/ do |field, value|
  page.fill_in(field, with: value)
end

Then /^the user sets the project "([^"]*)" date to "([^"]*)"$/ do |date_field_prefix, date_value|
  new_date = Chronic.parse(date_value).strftime('%Y-%m-%dT%T')
  page.find('#project_' + date_field_prefix + '_date').set(new_date)
end

Then /^the user selects "([^"]*)" as "([^"]*)"$/ do |value, field|
  page.select(value, from: field)
end

Then /^retrieve the latest project from the db$/ do
  @project = Project.last
end

Then /^the project "([^"]*)" date is "([^"]*)"$/ do |date_field_prefix, date_value|
  tz = ActiveSupport::TimeZone.new(@course.timezone)

  case date_field_prefix
  when 'start'
    date = Chronic.parse(date_value)
    date -= date.utc_offset
    date += tz.utc_offset
    date = date.getlocal(tz.utc_offset).beginning_of_day
    @project.start_date.should eq date

  when 'end'
    date = Chronic.parse(date_value)
    date += tz.utc_offset
    date = date.getlocal(tz.utc_offset).end_of_day
    @project.end_date.change(sec: 0).should eq date.change(sec: 0)
  else
    puts "We didn't test anything there: " + date_field_prefix + ' not found'
  end
end

Then /^the project "([^"]*)" is "([^"]*)"$/ do |field, value|
  case field.downcase
  when 'name'
    @project.name.should eq value
  when 'description'
    @project.description.should eq value
  else
    puts "We didn't test anything there: " + field + ' not found'
  end
end

Then /^the user clicks "([^"]*)" on the existing project$/ do |action|
  find(:xpath, "//tr[td[contains(.,'#{@project.name}')]]/td/a", text: action).click
end

Then /^the project Factor pack is "([^"]*)"$/ do |selected_factor_pack|
  @project.factor_pack.name.should eq selected_factor_pack
end

Then /^the project Style is "([^"]*)"$/ do |selected_style|
  @project.style.name.should eq selected_style
end

Given /^the course started "([^"]*)" and ended "([^"]*)"$/ do |start_date, end_date|
  @course.start_date = Chronic.parse(start_date)
  @course.end_date = Chronic.parse(end_date)
  @course.save
  puts @course.errors.full_messages unless @course.errors.blank?
end

Then /^set user (\d+) to group "([^"]*)"$/ do |user_number, group_name|
  user = User.all[1 + user_number.to_i]
  group = Group.where(name: group_name).take
  button_id = 'user_group_' + user.id.to_s + '_' + group.id.to_s

  page.choose(button_id)
end

Then /^group "([^"]*)" has (\d+) user$/ do |group_name, user_count|
  Group.where(name: group_name).take.users.count.should eq user_count.to_i
end

Then /^group "([^"]*)" has (\d+) revision$/ do |group_name, revision_count|
  Group.where(name: group_name).take.group_revisions.count.should eq revision_count.to_i
end

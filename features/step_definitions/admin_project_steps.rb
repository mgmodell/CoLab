require 'chronic'
# frozen_string_literal: true
Then /^the user "([^"]*)" see an Admin button$/ do |admin|
  if admin == 'does'
    page.should have_content('Admin…')
  else
    page.should_not have_content('Admin…')
  end
end

Given /^the user is an admin$/ do
  @user.admin = true
  @user.save
  puts @user.errors.full_messages if @user.errors.present?
end

Then /^the user clicks the Admin button$/ do
  click_link_or_button 'Admin…'
  click_link_or_button 'Administration'
end

Then /^the user sees (\d+) course$/ do |course_count|
  page.all('tr').count == course_count.to_i + 1
end

Given /^the user is the instructor for the course$/ do
  @course.set_user_role @user, Roster.roles[:instructor]
  @instructor = @user
end

Then('retrieve the instructor user') do
  @user = @instructor
end

Then /^the user opens the course$/ do
  click_link_or_button 'Show'
end

Then /^the user clicks "([^"]*)"$/ do |link_or_button|
  if has_xpath?("//button[contains(.,'#{link_or_button}')]",
                visible: :all)
    btn = find(:xpath, "//button[contains(.,'#{link_or_button}')]",
               match: :first,
               visible: :all)
  elsif has_xpath?("//a[contains(.,'#{link_or_button}')]",
                   visible: :all)
    btn = find(:xpath, "//a[contains(.,'#{link_or_button}')]",
               visible: :all)
  elsif has_xpath?("//input[@value='#{link_or_button}']",
                   visible: :all)
    btn = find(:xpath, "//input[@value='#{link_or_button}']",
               visible: :all)
  end
  begin
    retries ||= 0
    btn.click
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
    puts e.inspect
    retry if (retries += 1) < 4
  end
  # click_link_or_button link_or_button
end

Then /^the user switches to the "([^"]*)" tab$/ do |tab|
  click_link tab
end

Then 'the user enables the {string} table view option' do |view_option|
  find(:xpath, "//a[contains(text(), 'Show/Hide')]").click
  find(:xpath, "//label[contains(text(), '#{view_option}')]").click
  find(:xpath, '//body').send_keys :escape
end

Then /^the user sets the hidden tab field "([^"]*)" to "([^"]*)"$/ do |field, value|
  page.fill_in(field, with: value, visible: false)
end

Then /^the user sets the rich "([^"]*)" field to "([^"]*)"$/ do |field, value|
  field = find(:xpath,
               "//div[@id='rdw-wrapper-#{field}']//div[@contenteditable='true']")
  text = field.text
  field.send_keys :end
  text.length.times do
    field.send_keys :backspace
  end
  field.send_keys value
end

Then /^the user sets the "([^"]*)" field to "([^"]*)"$/ do |field, value|
  find_field(field).click
  find_field(field).set(value)
end

Then /^the user sets the project "([^"]*)" date to "([^"]*)"$/ do |date_field_prefix, date_value|
  new_date = Chronic.parse(date_value).strftime('%m/%d/%Y')
  page.find('#project_' + date_field_prefix + '_date').set(new_date)
end

Then /^the user selects "([^"]*)" as "([^"]*)"$/ do |value, field|
  id = find(:xpath,
            "//label[contains(text(),'#{field}')]")[:for]
  begin
    retries ||= 0
    selectCtrl = find_all(:xpath, "//select[@id='#{id}']")
  rescue NoMethodError => e
    retry if (retries += 1) < 4
  end

  if selectCtrl.empty?
    find(:xpath, "//div[@id='#{id}']", visible: :all).click
    find(:xpath, "//li[contains(text(),'#{value}')]").click
    sleep(0.3)
  else
    selectCtrl[0].select(value)
  end
end

Then /^retrieve the latest project from the db$/ do
  @project = Project.last
end

Then /^the project "([^"]*)" date is "([^"]*)"$/ do |date_field_prefix, date_value|
  puts @course.timezone
  course_tz = ActiveSupport::TimeZone.new(@course.timezone)

  case date_field_prefix.downcase
  when 'start'
    d = Chronic.parse(date_value)
    date = course_tz.local(d.year, d.month, d.day)
    @project.start_date.utc.should eq date.utc

  when 'end'
    d = Chronic.parse(date_value)
    date = course_tz.local(d.year, d.month, d.day).end_of_day
    @project.end_date.change(sec: 0).should eq date.change(sec: 0)
  else
    puts "We didn't test anything there: " + date_field_prefix + ' not found'
  end
end

Then /^the project "([^"]*)" is "([^"]*)"$/ do |field, value|
  case field.downcase.downcase
  when 'name'
    @project.name.should eq value
  when 'description'
    @project.description.should eq value
  else
    puts "We didn't test anything there: " + field + ' not found'
  end
end

Then /^the user clicks "([^"]*)" on the existing project$/ do |action|
  click_link_or_button 'Activities'
  elem = find(:xpath, "//tr[td[contains(.,'#{@project.name}')]]/td/a", text: action)
  elem.click
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
  puts @course.errors.full_messages if @course.errors.present?
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

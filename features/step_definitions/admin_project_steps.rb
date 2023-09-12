# frozen_string_literal: true

require 'chronic'
# frozen_string_literal: true
Then(/^the user "([^"]*)" see an Admin button$/) do |admin|
  find(:xpath, '//*[@id="main-menu-button"]').click
  if 'does' == admin
    page.should have_content('Administration')
  else
    page.should_not have_content('Administration')
  end
  page.document.first(:id, 'home-menu-item').send_keys :escape
end

Given(/^the user is an admin$/) do
  @user.admin = true
  @user.save
  log @user.errors.full_messages if @user.errors.present?
end

Then(/^the user clicks the Admin button$/) do
  find(:xpath, '//*[@id="main-menu-button"]').click
  find(:xpath, '//*[@id="administration-menu"]').click
end

Then(/^the user sees (\d+) course$/) do |course_count|
  wait_for_render
  page.all('tr').count == course_count.to_i + 1
end

Given(/^the user is the instructor for the course$/) do
  @course.set_user_role @user, Roster.roles[:instructor]
  @instructor = @user
end

Then('retrieve the instructor user') do
  @user = @instructor
end

Then(/^the user opens the course$/) do
  elem = find(:xpath, "//div[contains(@class,'MuiDataGrid-cell')]/div[contains(.,'#{@course.get_name(@anon)}')]")
  elem.click
end

Then(/^the user creates a new "([^"]*)"$/) do |link_or_button|
  wait_for_render
  find(:xpath, '//button[@aria-label="Add Activity"]').click
  find(:xpath, "//li[contains(.,'#{link_or_button}')]").click
  wait_for_render
end

Then('the user clicks {string}') do |link_or_button|
  wait_for_render

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
  else
    puts "nothing found yet for '#{link_or_button}"
    pending # nothing is found yet
  end
  begin
    retries ||= 0
    btn.click
  rescue NoMethodError => e
    puts e.inspect
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
    puts e.inspect
    if (retries += 1) < 4
      retry
    else
      true.should be false
    end
  end
  wait_for_render
end

Then('the user adds a group named {string}') do |group_name|
  button = 'Add Group'
  find(:xpath, "//button[contains(.,'#{button}')]",
       match: :first,
       visible: :all).click
  elem = find_field('g_-1')
  elem.set(group_name)
end

Then(/^the user switches to the "([^"]*)" tab$/) do |tab|
  begin
    click_link tab
  rescue Capybara::ElementNotFound
    find(:xpath, "//button[text()='#{tab}']").click
  end
  wait_for_render
end

Then 'the user enables the {string} table view option' do |view_option|
  find(:xpath, "//button[@aria-label='Select columns']").click
  inpt = find(:xpath, "//label[contains(.,'#{view_option}')]//input[@type='checkbox']", visible: :all)
  inpt.click unless inpt.checked?

  find(:xpath, '//body').click

end

Then(/^the user sets the hidden tab field "([^"]*)" to "([^"]*)"$/) do |field, value|
  page.fill_in(field, with: value, visible: false)
end

Then(/^the user sets the rich "([^"]*)" field to "([^"]*)"$/) do |field, value|
  field = find( :xpath, "//div[@id='#{field}']/div[@data-pc-section='content']" )
  text = field.text
  field.click
  send_keys :end
  text.length.times do
    send_keys :backspace
  end
  send_keys value
end

Then(/^the user sets the "([^"]*)" field to "([^"]*)"$/) do |field, value|
  find_field(field).click
  elem = find_field(field)
  elem.value.size.times do
    elem.send_keys :backspace
  end
  elem.set(value)
end

Then(/^the user sets the project "([^"]*)" date to "([^"]*)"$/) do |date_field_prefix, date_value|
  field_name = 'start' == date_field_prefix ? 'Project start date' : 'Project end date'
  find(:xpath, "//label[text()='#{field_name}']").click
  new_year = Chronic.parse(date_value).strftime('%Y')
  day_month = Chronic.parse(date_value).strftime('%m%d')
  send_keys :right, :right
  send_keys new_year
  send_keys :left, :left
  send_keys day_month
end

Then(/^the user selects "([^"]*)" as "([^"]*)"$/) do |value, field|
  id = find(:xpath,
            "//label[contains(text(),'#{field}')]")[:for]
  begin
    retries ||= 0
    selectCtrl = find_all(:xpath, "//select[@id='#{id}']")
  rescue NoMethodError
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

Then(/^retrieve the latest project from the db$/) do
  @project = Project.last
end

Then(/^the project "([^"]*)" date is "([^"]*)"$/) do |date_field_prefix, date_value|
  course_tz = ActiveSupport::TimeZone.new(@course.timezone)

  date = Chronic.parse(date_value)
  date = course_tz.local(
    date.year, date.month, date.day
  )

  case date_field_prefix.downcase
  when 'start'
    @project.start_date.utc.should eq date.utc

  when 'end'
    date = date.end_of_day.utc
    @project.end_date.change(sec: 0).should eq date.change(sec: 0)
  else
    log "We didn't test anything there: #{date_field_prefix} not found"
  end
end

Then(/^the project "([^"]*)" is "([^"]*)"$/) do |field, value|
  case field.downcase.downcase
  when 'name'
    @project.name.should eq value
  when 'description'
    @project.description.should eq value
  else
    log "We didn't test anything there: #{field} not found"
  end
end

Then('the user clicks on the existing project') do
  click_link_or_button 'Activities'
  elem = find(:xpath, "//div[contains(@class,'MuiDataGrid-cell')]/div[contains(.,'#{@project.get_name(@anon)}')]")
  elem.click
end

Then(/^the project Factor pack is "([^"]*)"$/) do |selected_factor_pack|
  @project.factor_pack.name.should eq selected_factor_pack
end

Then(/^the project Style is "([^"]*)"$/) do |selected_style|
  @project.style.name.should eq selected_style
end

Given(/^the course started "([^"]*)" and ended "([^"]*)"$/) do |start_date, end_date|
  @course.start_date = Chronic.parse(start_date)
  @course.end_date = Chronic.parse(end_date)
  @course.save
  log @course.errors.full_messages if @course.errors.present?
end

Then(/^set user (\d+) to group "([^"]*)"$/) do |user_number, group_name|
  user = User.all[1 + user_number.to_i]
  group = Group.where(name: group_name).take
  button_id = "user_group_#{user.id}_#{group.id}"

  find(:xpath, "//input[@id='#{button_id}']", visible: :all).click
end

Then(/^group "([^"]*)" has (\d+) user$/) do |group_name, user_count|
  Group.where(name: group_name).take.users.count.should eq user_count.to_i
end

Then(/^group "([^"]*)" has (\d+) revision$/) do |group_name, revision_count|
  Group.where(name: group_name).take.group_revisions.count.should eq revision_count.to_i
end

Then('the user selects the {string} menu item') do |menu_item|
  find(:xpath, "//*[@id='#{menu_item.downcase}-menu-item']").click
end

Then('the user clicks the {string} button') do |button_name|
  elem = find(:xpath, "//button[@aria-label='#{button_name}']")
  elem.click
end

Then('the user clicks the course {string} button') do |button_name|
  xquery = "//div[contains(.,'#{@course.get_name(false)}')]//button[@aria-label='#{button_name}']"
  elem = find(:xpath, xquery)
  elem.click
end

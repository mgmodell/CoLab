# frozen_string_literal: true

Then(/^the user should see "([^"]*)"$/) do |page_text|
  page.should have_content page_text
end

Given(/^the course timezone is "([^"]*)"$/) do |timezone|
  @course.timezone = timezone
  @course.save
  log @course.errors.full_messages if @course.errors.present?
end

Given(/^the user timezone is "([^"]*)"$/) do |timezone|
  @user.timezone = timezone
  @user.save
  log @user.errors.full_messages if @user.errors.present?
end

Given(/^the user sees (\d+) assessment every hour of the day$/) do |assessment_count|
  page.execute_script "Date = TimeShift.Date;"
  24.times do |_index|
    step "that the system's set_up_assessments process runs"
    visit '/'
    step "user should see #{assessment_count} open task"
    dest_date = DateTime.current + 30.minutes
    travel_to( dest_date )
    page.execute_script "TimeShift.setTime( #{dest_date.to_i} );"

    step "that the system's set_up_assessments process runs"
    visit '/'
    step "user should see #{assessment_count} open task"
    dest_date = DateTime.current + 30.minutes
    travel_to( dest_date )
    page.execute_script "TimeShift.setTime( #{dest_date.to_i} );"
  end
end

# frozen_string_literal: true

Given(/^today is "(.*?)"$/) do |destination_time|
  # Chronic.time_class = Time.zone
  @dest_date = Chronic.parse(destination_time).utc
  travel_to @dest_date
  if :rack_test != Capybara.current_driver && current_url.start_with?( 'http' )
    fill_in 'newTimeVal', with: @dest_date.to_s
    click_button 'setTimeBtn'
  end

  # The following line is often useful for debugging date issues
  # log "Date is now: #{Date.today}"
end

Then(/^the project should have (\d+) assessments attached to it$/) do |assessment_count|
  @project.assessments.count == assessment_count.to_i
end

Given(/^that the system's set_up_assessments process runs$/) do
  Assessment.set_up_assessments
end

Given(/^the course started "(.*?)" and ends "(.*?)"$/) do |start_date, end_date|
  @course.start_date = Chronic.parse(start_date)
  @course.end_date = Chronic.parse(end_date)
  @course.save
  log @course.errors.full_messages unless @course.errors.empty?
end

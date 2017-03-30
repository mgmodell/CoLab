
# frozen_string_literal: true
Given /^today is "(.*?)"$/ do |destination_time|
  # Chronic.time_class = Time.zone
  travel_to Chronic.parse(destination_time).utc
end

Then /^the project should have (\d+) assessments attached to it$/ do |assessment_count|
  @project.assessments.count == assessment_count.to_i
end

Given /^that the system's set_up_assessments process runs$/ do
  Assessment.set_up_assessments
end

Given /^the course started "(.*?)" and ends "(.*?)"$/ do |start_date, end_date|
  @course.start_date = Chronic.parse(start_date)
  @course.end_date = Chronic.parse(end_date)
end

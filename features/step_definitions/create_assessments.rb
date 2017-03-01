
Given /^today is "(.*?)"$/ do |destination_time|
  Chronic.time_class = Time.zone
  travel_to Chronic.parse(destination_time).utc
end

Then /^the project should have (\d+) assessments attached to it$/ do |assessment_count|
  @project.assessments.count == assessment_count.to_i
end

Given /^that the system's set_up_assessments process runs$/ do
  Assessment.set_up_assessments
end

Then /^return to the present$/ do
  travel_back
end

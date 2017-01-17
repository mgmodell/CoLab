require 'delorean'

Given /^today is "(.*?)"$/ do |destination_time|
  Delorean.time_travel_to( destination_time )
end


Then /^the project should have (\d+) assessments attached to it$/ do |assessment_count|
  @project.assessments.count == assessment_count.to_i
end

Given /^that the system's set_up_assessments process runs$/ do
  Assessment.set_up_assessments
end

Then /^return to the present$/ do
  Delorean.back_to_the_present
end

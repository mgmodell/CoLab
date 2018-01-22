# frozen_string_literal: true

Given /^there is a course$/ do
  @course = Course.make
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
end

Then /^the user sets the project to the course's project$/ do
  page.select(@project.name, from: 'Source of project groups', visible: :all)
end

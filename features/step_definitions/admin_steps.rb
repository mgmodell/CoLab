# frozen_string_literal: true

Given /^there is a course$/ do
  @course = School.find(1).courses.new(
    name: "#{Forgery::Name.industry} Course",
    number: Forgery::Basic.number,
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
end

Then /^the user sets the project to the course's project$/ do
  page.select(@project.name, from: 'Source of project groups', visible: :all)
end

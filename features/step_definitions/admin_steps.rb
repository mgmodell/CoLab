# frozen_string_literal: true

Given(/^there is a course$/) do
  @course = School.find(1).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within(range: 100..5000),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be.positive?
end

Then(/^the user sets the project to the course's project$/) do
  if has_select? 'Source of groups', visible: :all
    page.select(@project.name, from: 'Source of groups', visible: :all)
  else
    find('div', id: /bingo_game_project_id/).click
    find('li', text: @project.name).click

  end
end

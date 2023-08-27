# frozen_string_literal: true

require 'chronic'

Given('the course has an assignment named {string} with an {string} rubric named {string}') do |assignment_name, rubric_published, rubric_name|
  @rubric = @user.rubrics.new(
    name: rubric_name,
    description: Faker::GreekPhilosophers.quote,
    school: @user.school,
    published: 'published' == rubric_published
  )
  @rubric.criteria.new(
    description: Faker::Company.industry,
    sequence: 1,
    l1_description: Faker::Company.bs
  )
  @rubric.save
  log @rubric.errors.full_messages if @rubric.errors.present?

  @assignment = @course.assignments.new(
    name: assignment_name,
    description: Faker::Quote.yoda,
    passing: 65,
    start_date: 4.months.ago,
    end_date: 2.months.from_now,
    rubric: @rubric
  )
  @assignment.save
  log @assignment.errors.full_messages if @assignment.errors.present?
end

Given('the assignment opening is {string} and close is {string}') do |start_date_string, end_date_string|
  @assignment.start_date = Chronic.parse(start_date_string)
  @assignment.end_date = Chronic.parse(end_date_string)

  @assignment.save
  log @assignment.errors.full_messages if @assignment.errors.present?
end

Then('the assignment rubric is {string}') do |rubric_name|
  @assignment.rubric.name.should eq rubric_name
end

Then('the user sets the assignment {string} to {string}') do |field_name, value|
  case field_name
  when 'opening'
    label = 'Start Date'
    begin
      find(:xpath, "//label[text()='#{label}']").click
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError
      field_id = find(:xpath, "//label[text()='#{label}']")['for']
      field = find(:xpath, "//input[@id='#{field_id}']")
      field.click
    end
    new_year = Chronic.parse(value).strftime('%Y')
    new_date = Chronic.parse(value).strftime('%m%d%Y')
    send_keys :right, :right
    send_keys new_year
    send_keys :left, :left
    send_keys new_date
  when 'close'
    label = 'Close Date'
    begin
      find(:xpath, "//label[text()='#{label}']").click
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError
      field_id = find(:xpath, "//label[text()='#{label}']")['for']
      field = find(:xpath, "//input[@id='#{field_id}']")
      field.click
    end
    new_year = Chronic.parse(value).strftime('%Y')
    new_date = Chronic.parse(value).strftime('%m%d%Y')
    send_keys :right, :right
    send_keys new_year
    send_keys :left, :left
    send_keys new_date
  when 'link'
    if 'true' == value
      check 'sub_link', visible: :all
    else
      uncheck 'sub_link', visible: :all
    end
  when 'text'
    if 'true' == value
      check 'sub_text', visible: :all
    else
      uncheck 'sub_text', visible: :all
    end
  when 'files'
    if 'true' == value
      check 'sub_file', visible: :all
    else
      uncheck 'sub_file', visible: :all
    end
  else
    false.should be true
  end
end

Then('retrieve the {string} assignment from the db') do |which_assignment|
  @assignment = if 'latest' == which_assignment
                  Assignment.last
                else
                  Assignment.find_by name: which_assignment
                end
end

Then('the assignment {string} field is {string}') do |field_name, value|
  case field_name.downcase
  when 'name'
    @assignment.name.should eq value
  when 'description'
    @assignment.description.should eq "<p>#{value}</p>\n"
  when 'opening'
    @assignment.start_date.should eq Chronic.parse(value).to_date
  when 'close'
    @assignment.end_date.should eq Chronic.parse(value).end_of_day.change(sec: 59)
  else
    true.should be false
  end
end

Then('the assignment {string} active') do |is_active|
  @assignment.active.should eq('is' == is_active)
end

Then('the assignment {string} initialised as group-capable') do |is_group_enabled|
  @assignment.group_enabled = 'is' == is_group_enabled
end

Then('the user sets the assignment project to the course project') do
  project = @assignment.course.projects[0]
  if has_select? 'Source of groups', visible: :all
    page.select(project.name, from: 'Source of groups', visible: :all)
  else
    find('div', id: /assignment_project_id/).click
    find('li', text: project.name).click

  end
end

Then('the assignment project is the course project') do
  @assignment.project.should eq @course.projects[0]
end

Then('the user selects the {string} version {int} rubric') do |rubric_name, version|
  rubric = Rubric.where(name: rubric_name, version:)[0]
  if has_select? 'Which rubric will be applied?', visible: :all
    page.select("#{rubric.name} (#{rubric.version})", from: 'Which rubric will be applied?', visible: :all)
  else
    find('div', id: /assignment_rubric_id/).click
    find('li', text: "#{rubric.name} (#{rubric.version})").click

  end
end

Given('the course has an assignment') do
  @assignment = @course.assignments.new(
    name: Faker::Company.industry,
    description: Faker::Quote.yoda,
    passing: 65,
    start_date: 4.months.ago,
    end_date: 2.months.from_now,
    rubric: nil
  )
  @assignment.save
end

Given('the assignment {string} group capable') do |is_or_isnt|
  @assignment.group_enabled.should be 'is' == is_or_isnt
end

Then('the assignment rubric is {string} version {int}') do |rubric_name, rubric_version|
  @assignment.rubric.name.should eq rubric_name
  @assignment.rubric.version.should eq rubric_version
end

Then('the new assignment metadata is the same as the old') do
  @assignment.name.should eq @orig_assignment.name
  @assignment.description.should eq @orig_assignment.description
  @assignment.rubric.should eq @orig_assignment.rubric
  @assignment.file_sub.should eq @orig_assignment.file_sub
  @assignment.link_sub.should eq @orig_assignment.link_sub
  @assignment.text_sub.should eq @orig_assignment.text_sub
  @assignment.passing.should eq @orig_assignment.passing
  @assignment.group_enabled.should eq @orig_assignment.group_enabled
  @assignment.project.should eq @orig_assignment.project
end

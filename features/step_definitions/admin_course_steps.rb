# frozen_string_literal: true

require 'chronic'
require 'forgery'
Given 'the project started {string} and ends {string}' do |start_date, end_date|
  @project.start_date = Chronic.parse(start_date)
  @project.end_date = Chronic.parse(end_date)
  @project.save
end

Given "the user's school is {string}" do |school_name|
  school = School.find_by_name school_name
  @user.school = school
  @user.save
end

Then 'the user sets the start date to {string} and the end date to {string}' do |start_date, end_date|
  new_date = start_date.blank? ? '' : Chronic.parse(start_date).strftime('%Y-%m-%dT%T')
  page.find('#course_start_date').set(new_date)
  new_date = end_date.blank? ? '' : Chronic.parse(end_date).strftime('%Y-%m-%dT%T')
  page.find('#course_end_date').set(new_date)
end

Then 'the timezone {string} {string}' do |is_or_isnt, timezone|
  field_lbl = 'course_timezone'

  if is_or_isnt == 'is'
    page.find('#course_timezone').value.should eq timezone
  else
    page.find('#course_timezone').value.should_not eq timezone
  end
end

Then 'the user sets the course timezone to {string}' do |timezone|
  field_lbl = 'course_timezone'
  page.select(timezone, from: field_lbl)
end

Then 'retrieve the latest course from the db' do
  @orig_course = @course
  @course = Course.last
end

Then 'the course {string} field is {string}' do |field_name, value|
  case field_name.downcase
  when 'name'
    @course.name.should eq value
  when 'number'
    @course.number.should eq value
  when 'description'
    @course.description.should eq value
  when 'timezone'
    @course.timezone.should eq value
  else
    puts 'Not testing anything'
  end
end

Then 'the course start date is {string} and the end date is {string}' do |start_date, end_date|
  course_tz = ActiveSupport::TimeZone.new(@course.timezone)

  test_date = Chronic.parse(start_date)
                     .getlocal(course_tz.utc_offset)
                     .beginning_of_day
  @course.start_date.change(sec: 0).should eq test_date.change(sec: 0)

  test_date = Chronic.parse(end_date)
                     .getlocal(course_tz.utc_offset)
                     .end_of_day
  @course.end_date.change(sec: 0).should eq test_date.change(sec: 0)
end

Then 'the course {string} is {string}' do |field_name, value|
  case field_name.downcase
  when 'name'
    @course.name = value
  when 'number'
    @course.number = value
  when 'description'
    @course.description = value
  when 'timezone'
    @course.timezone = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @course.save
end

Then 'the user does not see a {string} link' do |link_name|
  page.has_link?(link_name).should eq false
end

Given 'the experience {string} is {string}' do |field_name, value|
  case field_name.downcase
  when 'name'
    @experience.name = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @experience.save
end

Given 'the Bingo! {string} is {string}' do |field_name, value|
  case field_name.downcase
  when 'description'
    @bingo.description = value
  when 'topic'
    @bingo.topic = value
  when 'terms count'
    @bingo.individual_count = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @bingo.save
end

Given 'the Bingo! {string} is {int}' do |field_name, value|
  case field_name.downcase
  when 'terms count'
    @bingo.individual_count = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @bingo.save
end

Given 'the Bingo! prep days is {int}' do |prep_days|
  @bingo.lead_time = prep_days
  @bingo.save
end

Given "the Bingo! project is the course's project" do
  @bingo.project = @course.projects.take
  @bingo.save
end

Given 'the Bingo! percent discount is {int}' do |group_discount|
  @bingo.group_discount = group_discount
  @bingo.save
end

Given 'the Bingo! is active' do
  @bingo.active = true
  @bingo.save
end

Then 'set the new course start date to {string}' do |new_date|
  @new_date = new_date
  fill_in 'New course start date?', with: @new_date
end

Then 'the course has {int} instructor user' do |instructor_count|
  @course.rosters.reload.instructor.count.should eq instructor_count
end

Then 'the user executes the copy' do
  url = copy_course_path + '?'
  url += { start_date: @new_date, id: @course.id }.to_param
  visit url
  @orig_course = @course
  @course = Course.last
end

Then 'the course instructor is the user' do
  @course.rosters.instructor.take.user.should eq @user
end

Then 'retrieve the {int} course {string}' do |index, activity|
  case activity.downcase
  when 'experience'
    @orig_experience = @experience
    @experience = @course.reload.experiences[index - 1]
  when 'project'
    @orig_project = @project
    @project = @course.reload.projects[index - 1]
  when 'bingo'
    @orig_bingo = @bingo
    @bingo = @course.reload.bingo_games[index - 1]
  end
end

Then 'the Experience {string} is {string}' do |field, value|
  case field.downcase
  when 'name'
    @experience.name.should eq value
  else
    puts "no test for '#{field}'"
    pending # Write code here that turns the phrase above into concrete
  end
end

Then 'the {string} dates are {string} and {string}' do |activity, start_date_str, end_date_str|
  course_tz = ActiveSupport::TimeZone.new(@course.timezone)
  d = Chronic.parse(start_date_str)
  start_date = course_tz.local(d.year, d.month, d.day).beginning_of_day
  d = Chronic.parse(end_date_str)
  end_date = course_tz.local(d.year, d.month, d.day).end_of_day.change(sec: 0)

  case activity.downcase
  when 'experience'
    @experience.start_date.should eq start_date
    @experience.end_date.should eq end_date.change(sec: 0)

  when 'project'
    @project.start_date.should eq start_date
    @project.end_date.should eq end_date.change(sec: 0)

  when 'bingo'
    @bingo.start_date.should eq start_date
    @bingo.end_date.should eq end_date.change(sec: 0)

  else
    pending # Write code here that turns the phrase above into concrete
  end
end

Then 'the {string} is {string} active' do |activity, active_bool|
  is_active = active_bool == 'is'

  case activity.downcase
  when 'experience'
    @experience.active.should eq is_active

  when 'project'
    @project.active.should eq is_active

  when 'bingo'
    @bingo.active.should eq is_active

  else
    pending # Write code here that turns the phrase above into concrete
  end
end

Then 'the new project metadata is the same as the old' do
  @project.name.should eq @orig_project.name
  @project.style.should eq @orig_project.style
  @project.factor_pack.should eq @orig_project.factor_pack
  @project.end_dow.should eq @orig_project.end_dow
  @project.start_dow.should eq @orig_project.start_dow
end

Then 'the project has {int} groups' do |group_count|
  @project.groups.count.should eq group_count
end

Then 'the new bingo metadata is the same as the old' do
  @bingo.topic.should eq @orig_bingo.topic
  @bingo.description.should eq @orig_bingo.description
  @bingo.link.should eq @orig_bingo.link
  @bingo.source.should eq @orig_bingo.source
  @bingo.group_option.should eq @orig_bingo.group_option
  @bingo.individual_count.should eq @orig_bingo.individual_count
  @bingo.lead_time.should eq @orig_bingo.lead_time
  @bingo.group_discount.should eq @orig_bingo.group_discount
end

Then 'the user adds the {string} users {string}' do |type, addresses|
  url = if type == 'student'
          add_students_path + '?'
        else
          add_instructors_path + '?'
        end
  addresses = @users.map(&:email).join(', ') if addresses == 'user_list'

  url += { addresses: addresses, id: @course.id }.to_param
  visit url
end

Then 'the user drops the {string} users {string}' do |type, addresses|
  url = if type == 'student'
          add_students_path + '?'
        else
          add_instructors_path + '?'
        end
  if addresses == 'user_list'
    @users.each do |address|
      elem = find(:xpath,
        "//tr[td[contains(.,'#{address.email}')]]/td/a", text: 'Drop')
      elem.click
    end
  else
    elem = find(:xpath,
      "//tr[td[contains(.,'#{addresses}')]]/td/a", text: 'Drop')
    elem.click
  end
end

Then 'there are {int} students in the course' do |count|
  @course.rosters.students.count.should eq count
end

Then 'there are {int} enrolled students in the course' do |count|
  @course.rosters.enrolled.count.should eq count
end

Then 'there are {int} instructors in the course' do |count|
  @course.rosters.faculty.count.should eq count
end

Then 'the users are students' do
  @users.each do |user|
    @course.rosters.students.where(user_id: user.id)
           .count.should eq 1
  end
end

Then 'the users are instructors' do
  @users.each do |user|
    @course.rosters.faculty.where(user_id: user.id)
           .count.should eq 1
  end
end

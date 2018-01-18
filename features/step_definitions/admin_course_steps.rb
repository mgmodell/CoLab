require 'chronic'
Given "the project started {string} and ends {string}"  do |start_date, end_date|
  @project.start_date = Chronic.parse( start_date )
  @project.end_date = Chronic.parse( end_date )
  @project.save
end

Given "the user's school is {string}" do |school_name|
  school = School.find_by_name school_name
  @user.school = school
  @user.save

end

Then "the user sets the start date to {string} and the end date to {string}"  do |start_date, end_date|
  new_date = start_date.blank? ? '' : Chronic.parse( start_date ).strftime('%Y-%m-%dT%T')
  page.find('#course_start_date').set(new_date)
  new_date = end_date.blank? ? '' : Chronic.parse( end_date ).strftime('%Y-%m-%dT%T')
  page.find('#course_end_date').set(new_date)
end

Then "the timezone {string} {string}"  do |is_or_isnt,timezone|
  field_lbl = 'course_timezone'

  if is_or_isnt == 'is'
    page.find('#course_timezone').value.should eq timezone
  else
    page.find('#course_timezone').value.should_not eq timezone
  end

end

Then "the user sets the course timezone to {string}" do |timezone|
  field_lbl = 'course_timezone'
  page.select( timezone, from: field_lbl )
  
end


Then "retrieve the latest course from the db"  do
  @course = Course.last

end

Then "the course {string} field is {string}"  do |field_name, value|
  case field_name
  when 'Name'
    @course.name.should eq value
  when 'Number'
    @course.number.should eq value
  when 'Description'
    @course.description.should eq value
  else
    puts "Not testing anything"
  end
  @course.save

end

Then "the course start date is {string} and the end date to {string}" do |start_date, end_date|
  test_date = start_date.blank? ? '' : Chronic.parse( start_date ).strftime('%Y-%m-%dT%T')
  @course.start_date.should eq test_date
  test_date = end_date.blank? ? '' : Chronic.parse( end_date ).strftime('%Y-%m-%dT%T')
  @course.end_date.should eq test_date

end

Then "the course {string} is {string}"  do |field_name, value|
  case field_name
  when 'Name'
    @course.name = value
  when 'Number'
    @course.number = value
  when 'Description'
    @course.description = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @course.save
end

Then "the user does not see a {string} link"  do |link_name|
  page.has_link?( link_name ).should eq false

end

Given "the experience {string} is {string}"  do |field_name, value|
  case field_name
  when 'Name'
    @course.name = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @course.save
end

Given "the Bingo! {string} is {string}"  do |field_name, value|
  case field_name
  when 'Description'
    @bingo.description = value
  when 'Topic'
    @bingo.topic = value
  when 'Terms count'
    @bingo.individual_count = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @bingo.save

end

Given "the Bingo! {string} is {int}"  do |field_name, value|
  case field_name
  when 'Terms count'
    @bingo.individual_count = value
  else
    puts "Not setting anything: #{value}"
    pending
  end
  @bingo.save

end

Given "the Bingo! prep days is {int}"  do |prep_days|
  @bingo.lead_time = prep_days
  @bingo.save

end

Given "the Bingo! project is the course's project"  do
  @bingo.project = @course.projects.take
  @bingo.save

end

Given "the Bingo! percent discount is {int}"  do |group_discount|
  @bingo.group_discount = group_discount

end

Given "the Bingo! is active"  do
  @bingo.active = true
  @bingo.save

end

Then "the user clicks the {string}"  do |string|
  pending # Write code here that turns the phrase above into concrete

end

Then "set the new course start date to {string}"  do |string|
  pending # Write code here that turns the phrase above into concrete

end

Then "the course has {int} instructor user"  do |int|
  pending # Write code here that turns the phrase above into concrete

end

Then "the course instructor is the user"  do
  pending # Write code here that turns the phrase above into concrete

end

Then "retrieve the {int} course {string}"  do |int, string|
  pending # Write code here that turns the phrase above into concrete

end

Then "the Experience {string} is {string}"  do |string, string2|
  pending # Write code here that turns the phrase above into concrete

end

Then "the new {string} dates are {string} and {string}"  do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete

end

Then "the new {string} is {string} active"  do |string, string2|
  pending # Write code here that turns the phrase above into concrete

end

Then "the new project metadata is the same as the old"  do
  pending # Write code here that turns the phrase above into concrete

end

Then "the new {string} started {string} and ends {string}"  do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete

end

Then "the new project has {int} groups"  do |int|
  pending # Write code here that turns the phrase above into concrete

end

Then "the new bingo metadata is the same as the old"  do
  pending # Write code here that turns the phrase above into concrete

end

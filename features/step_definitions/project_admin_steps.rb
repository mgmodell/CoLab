require "chronic"
# frozen_string_literal: true
Then /^the user "([^"]*)" see an Admin button$/ do |admin|
  if admin == 'does'
    page.should have_content('Admin')
  else
    page.should_not have_content('Admin')
  end
end

Given /^the user is an admin$/ do
  @user.admin = true
  @user.save
end

Then /^the user clicks the Admin button$/ do
  click_link_or_button 'Admin'
end

Then /^the user sees (\d+) course$/ do |course_count|
  page.all('tr').count == course_count.to_i + 1
end

Given /^the user is the instructor for the course$/ do
  Roster.create(user: @user, course: @course, role: Role.instructor.take)
end

Then /^the user opens the course$/  do
  click_link_or_button "Show"
end

Then /^the user clicks "([^"]*)"$/  do |link_or_button|
  click_link_or_button link_or_button
end

Then /^the user sets the hidden tab field "([^"]*)" to "([^"]*)"$/  do |field, value|
  puts page.body
  find( :xpath, "//input[@id='" + field + "']" ).set value
  #page.fill_in( field, with: value )
end

Then /^the user sets the "([^"]*)" field to "([^"]*)"$/  do |field, value|
  page.fill_in( field, with: value )
end

Then /^the user sets the "([^"]*)" date to "([^"]*)"$/  do |date_field_prefix, date_value|
  
  new_date = Chronic.parse( date_value ).strftime( "%Y-%m-%dT%T" )
  page.find('#project_' + date_field_prefix + '_date' ).set( new_date )
end

Then /^the user selects "([^"]*)" as "([^"]*)"$/  do |value, field|
  page.select( value, from: field )
end

Then /^retrieve the latest project from the db$/  do
  @project = Project.last
end

Then /^the project "([^"]*)" date is "([^"]*)"$/  do |date_field_prefix, date_value|
  puts "*************testing"
  tz = ActiveSupport::TimeZone.new( @course.timezone )
  puts tz
  puts tz.utc_offset

  case date_field_prefix
  when "start"
    date = Chronic.parse( date_value ).beginning_of_day - tz.utc_offset
    puts date
    puts @project.start_date
    puts @project.start_date.utc
    puts @project.start_date.zone
    puts "-----------"
    test_date = @project.start_date + tz.utc_offset
    puts @project.start_date
    puts test_date
    test_date.should eq date
  when "end"
    date = Chronic.parse( date_value ).end_of_day - tz.utc_offset
    date = date.change( :offset => 0 )
    puts date
    test_date = @project.end_date.change( offset: 0 )
    puts test_date
    test_date.should eq date
  else
    puts "We didn't test anything there: " + date_field_prefix + " not found"
  end
  
end

Then /^the project "([^"]*)" is "([^"]*)"$/  do |field, value|
  case field
  when "Name"
    @project.name.should eq value
  when "Description"
    @project.description.should eq value
  else
    puts "We didn't test anything there: " + field + " not found"
  end
end

Then /^the user clicks "([^"]*)" on the existing project$/  do |action|
  find( :xpath, "//tr[td[contains(.,'#{@project.name}')]]/td/a", :text=> action ).click
end

Then /^the project Factor pack is "([^"]*)"$/  do |selected_factor_pack|
  @project.factor_pack.name.should eq selected_factor_pack
end

Then /^the project Style is "([^"]*)"$/  do |selected_style|
  @project.style.name.should eq selected_style
end

Given /^the course started "([^"]*)" and ended "([^"]*)"$/ do |start_date,end_date|
  @course.start_date = Chronic.parse( start_date )
  @course.end_date = Chronic.parse( end_date )
  @course.save
end

Then /^set user (\d+) to group "([^"]*)"$/  do |user_number, group_name|
  user = User.all[ 1 + user_number.to_i ]
  group = Group.where( name: group_name ).take
  button_id = "user_group_" + user.id.to_s + "_" + group.id.to_s

  page.choose( button_id )

end

Then /^group "([^"]*)" has (\d+) user$/  do |group_name, user_count|
  Group.where( name: group_name ).take.users.count.should eq user_count.to_i
end

Then /^group "([^"]*)" has (\d+) revision$/  do |group_name, revision_count|
  Group.where( name: group_name ).take.group_revisions.count.should eq revision_count.to_i
end

Then /^show me the page$/  do
  puts page.body
end

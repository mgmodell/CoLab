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

Then /^the user sets the "([^"]*)" field to "([^"]*)"$/  do |field, value|
  page.fill_in( field, with: value )
end

Then /^the user sets the "([^"]*)" date to "([^"]*)"$/  do |date_field_prefix, date_value|
  puts "**************"
  puts page.find('#project_start_date' ).value
  puts page.find('#project_start_date' ).text
  page.find('#project_start_date' ).set( "2016-01-21T00:00:00" )
  page.find('#project_end_date' ).set( "2016-04-21T00:00:00" )
  #page.find( "#project_#{date_field_prefix.downcase}_date").set( date_value )
  #page.fill_in( date_field_prefix + " date", with: date_value.remove( "/" ) + "\t0000a" )
end

Then /^the user selects "([^"]*)" as "([^"]*)"$/  do |value, field|
  page.select( value, from: field )
end

Then /^retrieve the latest project from the db$/  do
  @project = Project.last
end

Then /^the project "([^"]*)" date is "([^"]*)"$/  do |date_field_prefix, date_value|
  case field
  when "Start"
    @project.start_date.should eq Chronic.parse( value )
  when "End"
    @project.end_date.should eq Chronic.parse( value )
  else
    puts "We didn't test anything there: " + field + " not found"
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
  @project.factor_pack.style.should eq selected_style
end

Given /^the course started "([^"]*)" and ended "([^"]*)"$/ do |start_date,end_date|
  @course.start_date = Chronic.parse( start_date )
  @course.end_date = Chronic.parse( end_date )
end

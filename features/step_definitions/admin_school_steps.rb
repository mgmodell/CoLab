# frozen_string_literal: true

require 'chronic'

Then 'retrieve the latest school from the db' do
  @orig_school = @school
  @school = School.last
end

Then 'the school {string} field is {string}' do |field_name, value|
  case field_name.downcase
  when 'name'
    @school.name.should eq value
  when 'description'
    @school.description.should eq value
  when 'timezone'
    @school.timezone.should eq value
  else
    log 'Not testing anything'
  end
end

Then 'the user sees {int} school' do |course_count|
  page.all('tr').count == course_count.to_i + 1
end

Then 'the user opens the school' do
  @school = School.last
  row = find(:xpath, "//tbody/tr/td[text()='#{@school.name}']" )
  row.click
end

Then 'the user selects {string} as the {string}' do |value, field|
  lbl = find(:xpath, "//label[text()='#{field}']")[:for]
  find(:xpath, "//*[@id='#{lbl}']").click
  find(:xpath, "//li[text()='#{value}']").click
end

Then 'the user will dismiss the error {string}' do |error_message|
  page.should have_content error_message
  find_all(:xpath, "//div[@data-pc-name='toast']//button[@data-pc-section='closebutton']").each(&:click)
end

Then(/^the user waits to see "([^"]*)"$/) do |wait_msg|
  wait_for_render

  counter = 0
  until page.has_text? wait_msg
    sleep 1
    counter += 1
    break if counter > 60
  end
end

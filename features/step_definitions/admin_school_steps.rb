# frozen_string_literal: true

require 'chronic'
require 'forgery'

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
    puts 'Not testing anything'
  end
end

Then 'the user sees {int} school' do |course_count|
  page.all('tr').count == course_count.to_i + 1
end

Then 'the user opens the school' do
  @school = School.last
  click_link_or_button @school.name
end

Then 'the user selects {string} as the {string}' do |value, field|
  select( value, from: field )

end

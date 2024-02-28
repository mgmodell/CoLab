# frozen_string_literal: true

Then 'retrieve the latest Experience from the db' do
  @experience = Experience.last
end

Then 'the experience start date is {string} and the end date is {string}' do |start_date, end_date|
  course_tz = ActiveSupport::TimeZone.new(@course.timezone)

  d = Chronic.parse(start_date)
  test_date = course_tz.local(d.year, d.month, d.day).beginning_of_day
  @experience.start_date.change(sec: 0).should eq test_date.change(sec: 0)

  d = Chronic.parse(end_date)
  test_date = course_tz.local(d.year, d.month, d.day).end_of_day
  @experience.end_date.change(sec: 0).should eq test_date.change(sec: 0)
end

Then 'the user edits the existing experience' do
  find( :xpath, "//tbody/tr/td[text()='#{@experience.name}']" ).click
  wait_for_render
end

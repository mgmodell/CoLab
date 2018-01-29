Then "retrieve the latest Experience from the db"  do
  @experience = Experience.last
end

Then "the user sets the experience {string} date to {string}" do |ordinal, date|
  new_date = date.blank? ? '' : Chronic.parse( date ).strftime('%Y-%m-%dT%T')
  case ordinal.downcase
  when 'start'
    page.find('#experience_start_date').set(new_date)
  when 'end'
    page.find('#experience_end_date').set(new_date)
  else
    puts "Invalid ordinal: #{ordinal}"
    pending
  end
end

Then "the experience start date is {string} and the end date is {string}" do |start_date, end_date|
  course_tz = ActiveSupport::TimeZone.new( @course.timezone )

  puts "\n\tTimezone: #{course_tz}"

  d = Chronic.parse( start_date )
  test_date = course_tz.local( d.year, d.month, d.day ).beginning_of_day
  @experience.start_date.change(sec: 0).should eq test_date.change(sec: 0)

  puts "end"
  d = Chronic.parse( end_date )
  test_date = course_tz.local( d.year, d.month, d.day ).end_of_day
  puts "end date: #{test_date.utc}"
  @experience.end_date.change(sec: 0).should eq test_date.change(sec: 0)

end

Then "the user clicks {string} on the existing experience"  do |action|
  find(:xpath, "//tr[td[contains(.,'#{@experience.name}')]]/td/a", text: action).click
end

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

  test_date = Chronic.parse( start_date )
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  test_date -= course_tz.utc_offset
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  test_date = test_date.getlocal( course_tz.utc_offset )
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  test_date = test_date.beginning_of_day
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  puts "\t\t++++ saved: #{@experience.start_date.strftime('%Y-%m-%d %T')}}"

  test_date = Chronic.parse( start_date )
    .getlocal( course_tz.utc_offset )
    .beginning_of_day
  @experience.start_date.should eq test_date

  test_date = Chronic.parse( end_date )
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  test_date -= course_tz.utc_offset
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  test_date = test_date.getlocal( course_tz.utc_offset )
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  test_date = test_date.beginning_of_day
  puts "\n\t\t++++ #{test_date.strftime('%Y-%m-%d %T')}"
  puts "\t\t++++ saved: #{@experience.end_date.strftime('%Y-%m-%d %T')}}"

  test_date = Chronic.parse( end_date )
    .getlocal( course_tz.utc_offset )
    .end_of_day
  @experience.end_date.should eq test_date
end

Then "the user clicks {string} on the existing experience"  do |action|
  find(:xpath, "//tr[td[contains(.,'#{@experience.name}')]]/td/a", text: action).click
end

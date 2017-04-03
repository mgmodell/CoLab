Given /^there is a course$/  do
  @course = Course.make
end

Given /^the course has a Bingo! game$/  do
  @bingo = BingoGame.make
  @bingo.course = @course
  @bingo.save
end

Then /^the user sets the project to the course's project$/  do
  page.select( @project.name, from: "Source of project groups" )
end

Then /^retrieve the latest Bingo! game from the db$/  do
  @bingo = BingoGame.last
end

Then /^the bingo "([^"]*)" is "([^"]*)"$/ do |arg1, arg2|
  case field.downcase
  when 'topic'
    @bingo.topic.should eq value
  when 'individual_count'
    @bingo.individual_count.should eq value
  when 'group_discount'
    @bingo.group_discount.should eq value
  when 'lead_time'
    @bingo.lead_time.should eq value
  else
    puts "We didn't test anything there: " + field + ' not found'
  end
end

Then /^the bingo project is the course's project$/  do
  @bingo.project.should eq @project
end

Then /^the bingo "([^"]*)" date is "([^"]*)"$/  do |arg1, arg2|
  tz = ActiveSupport::TimeZone.new(@course.timezone)

  case date_field_prefix
  when 'start'
    date = Chronic.parse(date_value)
    date -= date.utc_offset
    date += tz.utc_offset
    date = date.getlocal(tz.utc_offset).beginning_of_day
    @bingo.start_date.should eq date

  when 'end'
    date = Chronic.parse(date_value)
    date += tz.utc_offset
    date = date.getlocal(tz.utc_offset).end_of_day
    @bingo.end_date.change(sec: 0).should eq date.change(sec: 0)
  else
    puts "We didn't test anything there: " + date_field_prefix + ' not found'
  end

end


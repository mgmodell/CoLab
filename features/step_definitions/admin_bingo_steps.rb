Then /^the user sets the bingo "([^"]*)" date to "([^"]*)"$/ do |date_field_prefix, date_value|
  new_date = Chronic.parse(date_value).strftime('%Y-%m-%dT%T')
  page.find('#bingo_game_' + date_field_prefix + '_date').set(new_date)
end

Then /^the user clicks "([^"]*)" on the existing bingo game$/ do |action|
  find(:xpath, "//tr[td[contains(.,'#{@bingo.name}')]]/td/a", text: action).click
end

Then /^retrieve the latest Bingo! game from the db$/  do
  @bingo = BingoGame.last
end

Given /^the course has a Bingo! game$/  do
  @bingo = BingoGame.make
  @bingo.course = @course
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.nil?
end

Then /^the bingo "([^"]*)" is "([^"]*)"$/ do |field, value|
  case field.downcase
  when 'description'
    @bingo.description.should eq value
  when 'topic'
    @bingo.topic.should eq value
  when 'individual_count'
    @bingo.individual_count.should eq value.to_i
  when 'group_discount'
    @bingo.group_discount.should eq value.to_i
  when 'lead_time'
    @bingo.lead_time.should eq value.to_i
  else
    puts "We didn't test anything there: " + field + ' not found'
  end
end

Then /^the bingo project is the course's project$/  do
  @bingo.project_id.should eq @project.id
  @bingo.project.should eq @project
end

Then /^the bingo "([^"]*)" date is "([^"]*)"$/  do |date_field_prefix, date_value|
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

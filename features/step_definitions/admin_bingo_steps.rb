# frozen_string_literal: true

require 'forgery'

Then /^the user sets the bingo "([^"]*)" date to "([^"]*)"$/ do |date_field_prefix, date_value|
  new_date = Chronic.parse(date_value).strftime('%Y-%m-%dT%T')
  page.find('#bingo_game_' + date_field_prefix + '_date').set(new_date)
end

Then /^the user clicks "([^"]*)" on the existing bingo game$/ do |action|
  find(:xpath, "//tr[td[contains(.,'#{@bingo.get_name(@anon)}')]]/td/a", text: action).click
end

Then /^retrieve the latest Bingo! game from the db$/ do
  @bingo = BingoGame.last
end

Given /^the course has a Bingo! game$/ do
  @bingo = @course.bingo_games.new(
    topic: Forgery::Name.industry + ' Topic',
    description: Forgery::Basic.text,
    lead_time: 2,
    individual_count: 20,
    group_discount: 0,
    group_option: false
  )
  @bingo.save
  if @bingo.persisted?
    @bingo.get_topic(true).should_not be_nil
    @bingo.get_topic(true).length.should be > 0
  end
  puts @bingo.errors.full_messages unless @bingo.errors.blank?
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

Given /^the bingo started "([^"]*)" and ends "([^"]*)"$/ do |start_date, end_date|
  course_tz = ActiveSupport::TimeZone.new(@bingo.course.timezone)
  d = Chronic.parse(start_date)
  @bingo.start_date = course_tz.local(d.year, d.month, d.day)
  d = Chronic.parse(end_date)
  @bingo.end_date = course_tz.local(d.year, d.month, d.day)
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.blank?
end

Then /^the bingo project is the course's project$/ do
  @bingo.project_id.should eq @project.id
  @bingo.project.should eq @project
end

Then /^the bingo "([^"]*)" date is "([^"]*)"$/ do |date_field_prefix, date_value|
  course_tz = ActiveSupport::TimeZone.new(@bingo.course.timezone)

  case date_field_prefix.downcase
  when 'start'
    d = Chronic.parse(date_value)
    date = course_tz.local(d.year, d.month, d.day).beginning_of_day
    @bingo.start_date.should eq date

  when 'end'
    d = Chronic.parse(date_value)
    date = course_tz.local(d.year, d.month, d.day).end_of_day
    @bingo.end_date.change(sec: 0).should eq date.change(sec: 0)
  else
    puts "We didn't test anything there: " + date_field_prefix + ' not found'
  end
end

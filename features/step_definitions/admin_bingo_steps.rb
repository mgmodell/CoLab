# frozen_string_literal: true

require 'faker'

Then( /^the user sets the bingo "([^"]*)" date to "([^"]*)"$/ ) do | date_field_prefix, date_value |
  field_name = 'start' == date_field_prefix ? 'Open date' : 'Game date'
  begin
    find( :xpath, "//label[text()='#{field_name}']" ).click
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    field_id = find( :xpath, "//label[text()='#{label}']" )['for']
    field = find( :xpath, "//input[@id='#{field_id}']" )
    field.click
  end
  new_year = Chronic.parse( date_value ).strftime( '%Y' )
  # Be sure to enter the year first or leap years will break
  new_date = Chronic.parse( date_value ).strftime( '%m%d' )
  send_keys :right, :right
  send_keys new_year
  send_keys :left, :left
  send_keys new_date
end

Then( 'the user clicks on the existing bingo game' ) do
  find( :xpath, "//a[contains(.,'Activities')]" ).click
  find( :xpath, "//tbody/tr/td[text()='#{@bingo.get_name( @anon )}']" ).click
  wait_for_render
end

Then( /^retrieve the latest Bingo! game from the db$/ ) do
  @bingo = BingoGame.last
end

Given( /^the course has a Bingo! game$/ ) do
  @bingo = @course.bingo_games.new(
    topic: "#{Faker::Company.industry} Topic",
    description: Faker::Company.bs,
    lead_time: 2,
    individual_count: 20,
    group_discount: 0,
    project: @project,
    group_option: false,
    start_date: @course.start_date,
    end_date: @course.end_date
  )
  @bingo.save
  if @bingo.persisted?
    @bingo.get_topic( true ).should_not be_nil
    @bingo.get_topic( true ).length.should be > 0
  end
  log @bingo.errors.full_messages if @bingo.errors.present?
end

Then( /^the bingo "([^"]*)" is "([^"]*)"$/ ) do | field, value |
  case field.downcase
  when 'description'
    @bingo.description.strip.should eq value
  when 'topic'
    @bingo.topic.should eq value
  when 'individual_count'
    @bingo.individual_count.should eq value.to_i
  when 'group_discount'
    @bingo.group_discount.should eq value.to_i
  when 'lead_time'
    @bingo.lead_time.should eq value.to_i
  else
    log "We didn't test anything there: #{field} not found"
    pending
  end
end

Given( /^the bingo started "([^"]*)" and ends "([^"]*)"$/ ) do | start_date, end_date |
  course_tz = ActiveSupport::TimeZone.new( @bingo.course.timezone )
  d = Chronic.parse( start_date )
  @bingo.start_date = course_tz.local( d.year, d.month, d.day )
  d = Chronic.parse( end_date )
  @bingo.end_date = course_tz.local( d.year, d.month, d.day )
  @bingo.save
  log @bingo.errors.full_messages if @bingo.errors.present?
end

Then( /^the bingo project is the course's project$/ ) do
  @bingo.project_id.should eq @project.id
  @bingo.project.should eq @project
end

Then( /^the bingo "([^"]*)" date is "([^"]*)"$/ ) do | date_field_prefix, date_value |
  course_tz = ActiveSupport::TimeZone.new( @bingo.course.timezone )

  case date_field_prefix.downcase
  when 'start'
    d = Chronic.parse( date_value )
    date = course_tz.local( d.year, d.month, d.day ).beginning_of_day
    @bingo.start_date.should eq date

  when 'end'
    d = Chronic.parse( date_value )
    date = course_tz.local( d.year, d.month, d.day ).end_of_day
    @bingo.end_date.change( sec: 0 ).should eq date.change( sec: 0 )
  else
    log "We didn't test anything there: #{date_field_prefix} not found"
  end
end

Then( 'the {string} label is disabled' ) do | label |
  control = page.all( :xpath, "//label[contains(., '#{label}')][not(@disabled)]" )
  control.size.should be > 0
end

Then( 'the bingo project is empty' ) do
  @bingo.project.should be_nil
end

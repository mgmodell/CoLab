# frozen_string_literal: true

Then 'retrieve the latest Experience from the db' do
  @experience = Experience.last
end

Then 'the user sets the experience {string} date to {string}' do |ordinal, date_value|
  case ordinal.downcase
  when 'start'
    field_name = 'Experience Start Date'
    begin
      find(:xpath, "//label[text()='#{field_name}']").click
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError => ecie
      field_id = find(:xpath, "//label[text()='#{label}']")['for']
      field = find( :xpath, "//input[@id='#{field_id}']")
      field.click
    end
    new_year = Chronic.parse(date_value).strftime('%Y')
    new_date = Chronic.parse(date_value).strftime('%m%d')
    send_keys new_year
    send_keys :left, :left
    send_keys new_date
  when 'end'
    field_name = 'Experience End Date'
    begin
      find(:xpath, "//label[text()='#{field_name}']").click
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError => ecie
      field_id = find(:xpath, "//label[text()='#{label}']")['for']
      field = find( :xpath, "//input[@id='#{field_id}']")
      field.click
    end
    new_year = Chronic.parse(date_value).strftime('%Y')
    new_date = Chronic.parse(date_value).strftime('%m%d')
    send_keys new_year
    send_keys :left, :left
    send_keys new_date
  else
    log "Invalid ordinal: #{ordinal}"
    pending
  end
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

Then 'the user clicks {string} on the existing experience' do |_action|
  find(:xpath, "//td[contains(.,'#{@experience.name}')]").click
  # find(:xpath, "//tr[td[contains(.,'#{@experience.name}')]]/td/a", text: action).click
end

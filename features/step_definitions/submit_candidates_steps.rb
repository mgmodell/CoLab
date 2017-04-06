Given /^the Bingo! game required (\d+) day of lead time$/  do |lead_time|
  @bingo.lead_time = lead_time
  @bingo.save
end

Given /^the Bingo! started "([^"]*)" and ends "([^"]*)"$/  do |start_date, end_date|
  @bingo.start_date = Chronic.parse(start_date)
  @bingo.end_date = Chronic.parse(end_date)
  @bingo.save
end


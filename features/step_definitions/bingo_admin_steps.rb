Then /^the user sets the bingo "([^"]*)" date to "([^"]*)"$/ do |date_field_prefix, date_value|
  new_date = Chronic.parse(date_value).strftime('%Y-%m-%dT%T')
  page.find('#bingo_game_' + date_field_prefix + '_date').set(new_date)
end

Then /^the user clicks "([^"]*)" on the existing bingo game$/ do |action|
  find(:xpath, "//tr[td[contains(.,'#{@bingo.name}')]]/td/a", text: action).click
end

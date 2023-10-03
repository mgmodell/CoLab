# frozen_string_literal: true

require 'faker'

Given(/^the Bingo! game required (\d+) day of lead time$/) do |lead_time|
  @bingo.lead_time = lead_time
  @bingo.save
  log @bingo.errors.full_messages if @bingo.errors.present?
end

Given(/^the Bingo! started "([^"]*)" and ends "([^"]*)"$/) do |start_date, end_date|
  @bingo.reload
  @bingo.start_date = Chronic.parse(start_date)
  @bingo.end_date = Chronic.parse(end_date)
  @bingo.save
  log @bingo.errors.full_messages if @bingo.errors.present?
end

Given(/^the Bingo! game individual count is (\d+)$/) do |individual_count|
  @bingo.individual_count = individual_count
  @bingo.save
  log @bingo.errors.full_messages if @bingo.errors.present?
end

When(/^the user clicks the link to the candidate list$/) do
  wait_for_render
  step 'the user switches to the "Task View" tab'
  find(:xpath, "//div[@data-field='name']/div/div[contains(.,'#{@bingo.get_name(@anon)}')]").hover
  begin
    # Try to click regularly
    find(:xpath, "//div[@data-field='name']/div/div[contains(.,'#{@bingo.get_name(@anon)}')]").click
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    # If that gives an error, it's because of the readability popup
    # We can click either of the items this finds because they are effectively the same
    find_all(:xpath, "//div[contains(@class,'MuiBox') and contains(.,'#{@bingo.get_name(@anon)}')]")[0].click
  end
end

Then(/^the user should see the Bingo candidate list$/) do
  wait_for_render
  page.should have_content('Topic')
  page.should have_content(@bingo.topic)
  page.should have_content('For')
  page.should have_content(@user.name(@anon))
end

Then(/^the user will see (\d+) term field sets$/) do |count|
  wait_for_render
  page.all(:xpath,
           "//textarea[contains(@id, 'definition_')]")
      .count.should eq count.to_i
  page.all(:xpath,
           "//input[contains(@id, 'term_')]")
      .count.should eq count.to_i
end

Then(/^the candidate entries should be empty$/) do
  @bingo.individual_count.times do |index|
    query = "//input[@id='term_#{index}']"
    page.find(:xpath, query).value.should eq ''
    query = "//textarea[@id='definition_#{index}']"
    page.find(:xpath, query).value.should eq ''
  end
end

Then(/^the candidate properties should be empty$/) do
  cl = @bingo.candidate_list_for_user @user
  cl.candidates.each do |candidate|
    candidate.term.should eq ''
    candidate.definition.should eq ''
  end
end

When('the user populates {int} of the {string} entries') do |count, field|
  @entries_lists = {} if @entries_lists.nil?
  @entries_lists[@user] = [] if @entries_lists[@user].nil?
  @entries_list = @entries_lists[@user]

  # Support a current list of all entries
  @entries_lists['all'] = [] if @entries_lists['all'].nil?
  entries_list_a = @entries_lists['all']

  count.to_i.times do |index|
    @entries_list[index] = {} if @entries_list[index].nil?
    @entries_list[index][field] = if 'term' == field
                                    "#{Faker::Company.industry}_#{index}"
                                  else
                                    Faker::Company.bs
                                  end

    entries_list_a[index] = {} if entries_list_a[index].nil?
    entries_list_a[index][field] = @entries_list[index][field]

    page.fill_in("#{field}_#{index}",
                 with: @entries_list[index][field])
  end
end

Then('the candidate list properties will match the list') do
  cl = @bingo.candidate_list_for_user @user
  @entries_list.each do |cand|
    cl.candidates.where(term: cand['term'], definition: cand['definition']).count.should eq 1
  end
end

Then('the candidate list entries should match the list') do
  field_count = page.all(:xpath, "//textarea[contains(@id, 'definition_')]").count

  field_count.times do |index|
    t_query = "//input[@id='term_#{index}']"
    d_query = "//textarea[@id='definition_#{index}']"
    term = find(:xpath, t_query).value
    definition = find(:xpath, d_query).value

    next unless term.present? || definition.present?

    entry = @entries_lists['all'].find do |candidate|
      elem_term = candidate['term'].blank? ? candidate['term'] : candidate['term'].strip.split.map(&:capitalize) * ' '
      term == elem_term && definition == candidate['definition']
    end
    byebug unless true == entry.present?
    entry.present?.should eq true
  end
end

Given('the Bingo! {string} been activated') do |has_or_has_not|
  @bingo.active = 'has' == has_or_has_not
  @bingo.save
  log @bingo.errors.full_messages if @bingo.errors.present?
end

Then('the {string} button is not available') do |button_name|
  btns = all(:xpath, "//button[text()='#{button_name}']")
  btns.each do |btn|
    btn[:disabled].should be true
  end
end

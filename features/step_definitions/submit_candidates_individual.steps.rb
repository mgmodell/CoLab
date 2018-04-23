# frozen_string_literal: true

require 'forgery'

Given /^the Bingo! game required (\d+) day of lead time$/ do |lead_time|
  @bingo.lead_time = lead_time
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.blank?
end

Given /^the Bingo! started "([^"]*)" and ends "([^"]*)"$/ do |start_date, end_date|
  @bingo.reload
  @bingo.start_date = Chronic.parse(start_date)
  @bingo.end_date = Chronic.parse(end_date)
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.blank?
end

Given /^the Bingo! game individual count is (\d+)$/ do |individual_count|
  @bingo.individual_count = individual_count
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.blank?
end

When /^the user clicks the link to the candidate list$/ do
  first(:link, @bingo.get_name(@anon)).click
  # click_link_or_button @bingo.get_name(@anon)
end

Then /^the user should see the Bingo candidate list$/ do
  page.should have_content('Topic:')
  page.should have_content(@bingo.topic)
  page.should have_content('For:')
  page.should have_content(@user.name(@anon))
end

Then /^the user will see (\d+) term field sets$/ do |count|
  page.all(:xpath,
           "//textarea[contains(@id, '_definition')]")
      .count.should eq count.to_i
  page.all(:xpath,
           "//input[contains(@id, '_term')]")
      .count.should eq count.to_i
end

Then /^the candidate entries should be empty$/ do
  @bingo.individual_count.times do |index|
    query = "//input[@id='candidate_list_candidates_attributes_#{index}_term']"
    page.find(:xpath, query).value.should eq ''
    query = "//textarea[@id='candidate_list_candidates_attributes_#{index}_definition']"
    page.find(:xpath, query).value.should eq ''
  end
end

Then /^the candidate properties should be empty$/ do
  cl = @bingo.candidate_list_for_user @user
  cl.candidates.each do |candidate|
    candidate.term.should eq ''
    candidate.definition.should eq ''
  end
end

When /^the user populates (\d+) of the "([^"]*)" entries$/ do |count, field|
  @entries_lists = {} if @entries_lists.nil?
  @entries_lists[@user] = [] if @entries_lists[@user].nil?
  @entries_list = @entries_lists[@user]
  count.to_i.times do |index|
    @entries_list[index] = {} if @entries_list[index].nil?
    @entries_list[index][field] = field == 'term' ?
                        Forgery::Name.industry :
                        Forgery::Basic.text
    page.fill_in("candidate_list_candidates_attributes_#{index}_#{field}",
                 with: @entries_list[index][field])
  end
end

Then /^the candidate list properties will match the list$/ do
  cl = @bingo.candidate_list_for_user @user
  @entries_list.each do |cand|
    cl.candidates.where(term: cand['term'], definition: cand['definition']).count.should eq 1
  end
end

Then /^the candidate list entries should match the list$/ do
  field_count = page.all(:xpath, "//textarea[contains(@id, '_definition')]") .count

  items_not_found = @entries_lists[@user].count
  @entries_lists[@user].each do |candidate|
    field_count.times do |index|
      t_query = "//input[@id='candidate_list_candidates_attributes_#{index}_term']"
      d_query = "//textarea[@id='candidate_list_candidates_attributes_#{index}_definition']"
      term = candidate['term'].blank? ? candidate['term'] : candidate['term'].strip.split.map(&:capitalize) * ' '
      if page.find(:xpath, t_query).value == term &&
         page.find(:xpath, d_query).value == candidate['definition']
        items_not_found -= 1
      end
    end
  end
  items_not_found.should eq 0
end

Given(/^the Bingo! "([^"]*)" been activated$/) do |has_or_has_not|
  @bingo.active = has_or_has_not == 'has'
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.blank?
end

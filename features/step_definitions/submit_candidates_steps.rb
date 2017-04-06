require 'forgery'

Given /^the Bingo! game required (\d+) day of lead time$/  do |lead_time|
  @bingo.lead_time = lead_time
  @bingo.save
end

Given /^the Bingo! started "([^"]*)" and ends "([^"]*)"$/  do |start_date, end_date|
  @bingo.start_date = Chronic.parse(start_date)
  @bingo.end_date = Chronic.parse(end_date)
  @bingo.save
end

Given /^the Bingo! game individual count is (\d+)$/  do |individual_count|
  @bingo.individual_count = individual_count
  @bingo.save
  
end

When /^the user clicks the link to the candidate list$/  do
  click_link_or_button "Bingo! terms: " + @bingo.name
end

Then /^the user should see the Bingo candidate list$/  do
  page.should have_content( "Topic:" )
  page.should have_content( @bingo.topic )
  page.should have_content( "For:" )
  page.should have_content( @user.name )
end

Then /^the user will see (\d+) "([^"]*)" fields$/  do |count, field_name|
  # We should have an id, a term and a definition for each candidate (*3)
  page.all( :xpath, 
            '//input[starts-with(@id, "candidate_list_candidates_attributes_")]').
            count.should eq (count * 3 )
end

Then /^the candidate entries should be empty$/ do
  @bingo.individual_count.each do |index|
    query = "//input[@id='candidate_list_candidates_attributes_" + index.to_s + "_term']"
    page.find( :xpath, query ).value.should eq ""
    query = "//input[@id='candidate_list_candidates_attributes_" + index.to_s + "_definition']"
    page.find( :xpath, query ).value.should eq ""
  end
end

Then /^the candidate properties should be empty$/ do
  cl = @bingo.candidate_list_for_user user
  cl.candidates.each do |candidate|
    candidate.term.should eq ""
    candidate.definition.should eq ""
  end
end

When /^the user populates (\d+) of the "([^"]*)" entries$/  do |count, field|
  @entries_lists = { } if @entries_lists.nil?
  entries = @entries_list[ field ].nil? ? [ ] : @entries_list[ field ]
  count.each do |index|
    entries[ index ] = field == "term" ? Forgery::Name.industry : Forgery::Basic.text
    page.fill_in( "candidate_list_candidates_attributes_" + index.to_s + "_" + field,
                with: entries[ index ] )
  end
end

Then /^the candidate list properties will match the list$/  do
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^the candidate list entries should match the list$/  do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^the Bingo! "([^"]*)" been activated$/) do |has_or_has_not|
  @bingo.active = has_or_has_not == 'has'
  @bingo.save
end

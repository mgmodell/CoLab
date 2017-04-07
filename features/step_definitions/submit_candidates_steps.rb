require 'forgery'

Given /^the Bingo! game required (\d+) day of lead time$/  do |lead_time|
  @bingo.lead_time = lead_time
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.nil?
end

Given /^the Bingo! started "([^"]*)" and ends "([^"]*)"$/  do |start_date, end_date|
  @bingo.start_date = Chronic.parse(start_date)
  @bingo.end_date = Chronic.parse(end_date)
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.nil?
end

Given /^the Bingo! game individual count is (\d+)$/  do |individual_count|
  @bingo.individual_count = individual_count
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.nil?
  
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

Then /^the user will see (\d+) term field sets$/  do |count|
  page.all( :xpath, 
            "//textarea[contains(@id, '_definition')]").
            count.should eq (count.to_i )
  page.all( :xpath, 
            "//input[contains(@id, '_term')]").
            count.should eq (count.to_i )
end

Then /^the candidate entries should be empty$/ do
  @bingo.individual_count.times do |index|
    query = "//input[@id='candidate_list_candidates_attributes_#{index}_term']"
    page.find( :xpath, query ).value.should eq ""
    query = "//textarea[@id='candidate_list_candidates_attributes_#{index}_definition']"
    page.find( :xpath, query ).value.should eq ""
  end
end

Then /^the candidate properties should be empty$/ do
  cl = @bingo.candidate_list_for_user @user
  cl.candidates.each do |candidate|
    candidate.term.should eq ""
    candidate.definition.should eq ""
  end
end

When /^the user populates (\d+) of the "([^"]*)" entries$/  do |count, field|
  @entries_list = Array.new if @entries_list.nil?
  count.to_i.times do |index|
    @entries_list[ index ] = Hash.new if @entries_list[ index ].nil?
    @entries_list[ index ][ field ] = field == "term" ? 
                        Forgery::Name.industry : 
                        Forgery::Basic.text
    page.fill_in( "candidate_list_candidates_attributes_#{index.to_s}_#{field}",
                with: @entries_list[ index ][ field ] )
  end
end

Then /^the candidate list properties will match the list$/  do
  cl = @bingo.candidate_list_for_user @user
  cl.candidates.each_with_index do |candidate,index|
    candidate.term.should eq @entries_list[ index ][ "term" ]
    candidate.definition.should eq @entries_list[ index ][ "definition" ]
  end
end

Then /^the candidate list entries should match the list$/  do
  @entries_list.each_with_index do |candidate,index|
    query = "//input[@id='candidate_list_candidates_attributes_#{index}_term']"
    page.find( :xpath, query ).value.should eq candidate[ "term" ]
    query = "//textarea[@id='candidate_list_candidates_attributes_#{index}_definition']"
    page.find( :xpath, query ).value.should eq candidate[ "definition" ]
  end
end

Given(/^the Bingo! "([^"]*)" been activated$/) do |has_or_has_not|
  @bingo.active = has_or_has_not == 'has'
  @bingo.save
  puts @bingo.errors.full_messages unless @bingo.errors.nil?
end

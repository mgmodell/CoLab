# frozen_string_literal: true
Given /^the user is any student in the course$/ do
  @user = @course.rosters.enrolled.sample.user
end

Then /^the user clicks the link to the concept list$/ do
  click_link_or_button @bingo.get_name(@anon)
end

Then /^the concept list should match the list$/ do
  @bingo.concepts.uniq.each do |concept|
    page.find(:xpath, "//tr[@id='concept']/td[text()='#{concept.name}']").should_not be_nil
  end
end

Then /^the user should see (\d+) concepts$/ do |concept_count|
  page.should have_content 'Terms List for Review'
  page.all(:xpath, "//tr[@id='concept']").count.should eq concept_count.to_i
end

Then /^the number of concepts is less than the total number of concepts$/ do
  page.all(:xpath, "//tr[@id='concept']").count.should be < Concept.count
end

# frozen_string_literal: true

require 'faker'

Given('{int} user has submitted to the assignment') do |count|
  count.times do
    user = @assignment.course.enrolled_students.sample
    submitted = DateTime.now
    submission = Submission.new(
      sub_link: Faker::Internet.url,
      rubric: @assignment.rubric,
      assignment: @assignment,
      user:,
      submitted:,
      recorded_score: nil
    )
    submission.save
  end
end

Given('the submission has been withdrawn') do
  submission = Submission.last
  submission.withdrawn = DateTime.now
  unless submission.save
    puts submission.errors.full_messages
    true.should be false
  end
end

Then('the user selects submission {int}') do |index|
  row = find(:xpath, "//div[@data-rowindex='#{index - 1}']")
  row.click
  submission_id = row['data-id'].to_i
  @submission = Submission.find submission_id
  @submission.should be_present
  wait_for_render
end

Then('the user hides all but the {string} tab') do |tabname|
  tabs = find_all( :xpath, "//div[@role='group']/button[not(text()='#{tabname}') " + 
                            "and @aria-pressed='true']" )
  tabs.each do |tab|
    tab.click
  end
  tabs = find_all( :xpath, "//div[@role='group']/button[text()='#{tabname}' " + 
                            "and @aria-pressed='false']" )
  tabs.each do |tab|
    tab.click
  end
end

Then('the contents match the submission contents') do
  find_all(:xpath, "//p[@id='sub_link']/a[@href='#{@submission.sub_link}']").size.should be 1
  find_all(:xpath, "//p[@id='sub_text' and contains(.,'#{@submission.sub_text}')]").size.should be 1
end

Then('the user enters overall feedback') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user responds to all criteria with {string} and {string} feedback') do |_string, _string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user saves the critique') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the db critique matches the data entered') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user selects the {string} submission') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sets score to {int}') do |_int|
  # Then('the user sets score to {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the user is an {string} user in the course') do |user_type|
  case user_type
  when 'instructor'
    @user = @assignment.course.instructors.sample
  else
    puts "User type of '#{user_type}' not handled"
    pending
  end
  @user.should_not be_nil
end
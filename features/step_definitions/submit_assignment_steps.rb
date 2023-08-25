require 'faker'

Given('the assignment {string} accept {string}') do |does_or_doesnt, sub_type|
  case sub_type.downcase
  when 'text'
    @assignment.text_sub.should eq('does' == does_or_doesnt)
  when 'link'
    @assignment.link_sub.should eq('does' == does_or_doesnt)
  when 'files'
    @assignment.file_sub.should eq('does' == does_or_doesnt)
  else
    true.should be false
  end
end

Given('the init assignment {string} accept {string}') do |does_or_doesnt, sub_type|
  case sub_type.downcase
  when 'text'
    @assignment.text_sub = 'does' == does_or_doesnt
  when 'links'
    @assignment.link_sub = 'does' == does_or_doesnt
  when 'files'
    @assignment.file_sub = 'does' == does_or_doesnt
  else
    true.should be false
  end
  @assignment.save
  log @assignment.errors.full_messages if @assignment.errors.present?
end

Given('the assignment {string} initialized active') do |is_or_isnt|
  @assignment.active = 'is' == is_or_isnt
  @assignment.save
end

Given('the course is shifted {int} {string} into the {string}') do |qty, units, direction|
  shift = 0
  case units.downcase
  when 'years'
    shift = qty.years
  when 'months'
    shift = qty.months
  when 'days'
    shift = qty.days
  else
    true.should be false
  end

  shift = shift * -1 unless direction.downcase == 'future'

  ActiveRecord::Base.transaction do
    @course.start_date += shift
    @course.end_date += shift

    # Experiences
    @course.experiences.find_each do |experience|
      experience.start_date += shift
      experience.end_date += shift
      experience.save
    end
    # Projects
    @course.projects.find_each do |project|
      project.start_date += shift
      project.end_date += shift
      project.save
    end
    # assignments
    @course.assignments.find_each do |assignment|
      assignment.start_date += shift
      assignment.end_date += shift
      assignment.save
    end
    # bingo_games
    @course.bingo_games.find_each do |bingo_game|
      bingo_game.start_date += shift
      bingo_game.end_date += shift
      bingo_game.save
    end
    @course.save # validate: false
    true.should be false if @course.errors.present?

  end

end

Then('the user opens the assignment task') do 
  wait_for_render
  step 'the user switches to the "Task View" tab'
  find(:xpath, "//div[@data-field='name']/div/div[contains(.,'#{@assignment.name}')]").hover
  begin
    # Try to click regularly
    find(:xpath, "//div[@data-field='name']/div/div[contains(.,'#{@assignment.name}')]").click
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
    # If that gives an error, it's because of the readability popup
    # We can click either of the items this finds because they are effectively the same
    find_all(:xpath, "//div[contains(@class,'MuiBox') and contains(.,'#{@assignment.name}')]")[0].click
  end
  wait_for_render

end

Then('the user opens the assignment history item') do 
  wait_for_render
  find(:xpath, "//div[@data-field='name']/div/div[contains(.,'#{@assignment.name}')]").hover
  begin
    # Try to click regularly
    find(:xpath, "//div[@data-field='name']/div/div[contains(.,'#{@assignment.name}')]").click
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
    # If that gives an error, it's because of the readability popup
    # We can click either of the items this finds because they are effectively the same
    find_all(:xpath, "//div[contains(@class,'MuiBox') and contains(.,'#{@assignment.name}')]")[0].click
  end
  wait_for_render
end

Then('the user opens the {string} submissions tab') do |tab_name|
  wait_for_render
  case tab_name
  when 'Submissions'
    click_link_or_button 'Responses'
    # find(:xpath, "//div[@role='tablist']/button[text()='Responses']").click
  when 'Grading'
    click_link_or_button 'Progress'
    # find(:xpath, "//div[@role='tablist']/button[text()='Progress']").click
  else
    true.should be false
  end
end

Then('the shown rubric matches the assignment rubric') do
  page.should have_content @assignment.name
  page.should have_content @assignment.description

  rubric = @assignment.rubric
  page.should have_content rubric.name
  page.should have_content rubric.version

  rubric.criteria.each do |criterium|
    page.should have_content criterium.description
    page.should have_content criterium.l1_description
    page.should have_content criterium.l2_description unless criterium.l2_description.nil?
    page.should have_content criterium.l3_description unless criterium.l3_description.nil?
    page.should have_content criterium.l4_description unless criterium.l4_description.nil?
    page.should have_content criterium.l5_description unless criterium.l5_description.nil?

  end
end

Then('the {string} tab {string} enabled') do |tab_name, enabled|
  case tab_name.downcase
  when 'submissions'
    tab = find(:xpath, "//button[text()='Responses']")
  when 'grading'
    tab = find(:xpath, "//button[text()='Progress']")
  else
    true.should be false
  end
  (tab['disabled'] == 'true').should be 'is' != enabled
end

Then('the user creates a new submission') do
  find( :xpath, "//button[text()='New response']")
end

Then('the user enters a {string} submission') do |submission_type|
  case submission_type.downcase
  when 'text'
    find(:xpath, "//div[@class='rdw-editor-main']").click
    rand(6).times do
      send_keys Faker::Lorem.paragraph, :enter
    end
  else  
    pending # Write code here that turns the phrase above into concrete actions
  end
end

Then('the assignment has {int} {string} submission') do |_int, _string|
  # Then('the assignment has {float} {string} submission') do |float, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the {string} db submission data is accurate') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the submission has no group') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the submission is attached to the user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the assignment already has {int} submission from the user') do |count|
  count.times do |index|
    submission = @assignment.submissions.new(
      submitted: (count - index ).hours.ago,
      sub_text: Faker::Books::Lovecraft.sentence(word_count: rand(50..150)),
      user: @user,
      rubric: @assignment.rubric
    )
    submission.save

    log submission.errors.full_messages if submission.errors.present?
    true.should be false if submission.errors.present?
  end
end

Then('the latest {string} db submission data is accurate') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('today is between the first assignment deadline and close') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('today is after the final deadline') do
  travel_to @assignment.end_date
end

Then('the user withdraws submission {int}') do |_int|
  # Then('the user withdraws submission {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('assignment {int} {string} graded') do |_int, _string|
  # Given('assignment {float} {string} graded') do |float, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user {string} withdraws submission {int}') do |_string, _int|
  # Then('the user {string} withdraws submission {float}') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

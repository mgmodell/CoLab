# frozen_string_literal: true

Given(/^the users "([^"]*)" prep "([^"]*)"$/) do |completion_level, group_or_solo|
  # Store the previous user (do no harm)
  temp_user = @user

  user_group = @users
  # If we're working with a group, as a group, then...
  if group_or_solo == 'as a group'
    collab_requested = false
    @users.each do |user|
      @user = user
      step 'the user "has" had demographics requested'
      step 'the user logs in'
      step 'user should see 1 open task'
      step 'the user clicks the link to the candidate list'
      step 'the user should see the Bingo candidate list'

      if !collab_requested
        step 'the user requests collaboration'
        collab_requested = true
      else
        step 'the user "accepts" the collaboration request'
      end

      step 'the user logs out'
    end
    user_group = [@users.sample]
  end

  @user = @users.sample
  step 'the user "has" had demographics requested'
  step 'the user logs in'
  step 'the user clicks the link to the candidate list'
  fields = page.all(:xpath, "//input[contains(@id, 'term_')]").count
  step 'the user logs out'

  # set up how much we want to complete
  case completion_level.downcase
  when 'finish'
    fields_to_complete = fields
  when 'incomplete'
    fields_to_complete = fields / 2
  when 'don\'t'
    fields_to_complete = 0
  else
    log "we didn't test anything here: #{completion_level}"
  end

  user_group.each do |user|
    @user = user
    step 'the user "has" had demographics requested'
    step 'the user logs in'
    step 'the user clicks the link to the candidate list'
    step "the user populates #{fields_to_complete} of the \"term\" entries"
    step "the user populates #{fields_to_complete} of the \"definition\" entries"
    step 'the user clicks "Save"' if fields_to_complete.positive?
    step 'the user will see "success"'
    step 'the user logs out'
  end

  # Reset back to previous user (whomever that was)
  @user = temp_user
end

Then(/^the user sees (\d+) candidate items for review$/) do |candidate_count|
  wait_for_render
  # Enable max rows
  max_rows = @bingo.candidates.size
  page.find(:xpath, "//div[@id='pagination-rows']").click
  page.find(:xpath, "//li[text()='#{max_rows}']").click

  page.all(:xpath, "//div[contains(@id, 'feedback_4_')]")
      .count.should eq candidate_count.to_i
  # Latest UI only shows 'Concept' when relevant/available
  # page.all(:xpath, "//input[contains(@id, 'concept_4_')]")
  #    .count.should eq candidate_count.to_i
end

Given(/^the user sees review items for all the expected candidates$/) do
  @bingo.candidates.completed.each do |candidate|
    # Latest UI only shows 'Concept' when relevant/available
    # page.all(:xpath, "//input[@id='concept_4_#{candidate.id}']").count.should eq 1
    page.all(:xpath,
             "//div[@id='feedback_4_#{candidate.id}']",
             visible: false).count.should eq 1
  end
end

Then(/^the user waits while seeing "([^"]*)"$/) do |wait_msg|
  wait_for_render

  counter = 0
  while page.has_text? wait_msg
    sleep 1
    counter += 1
    break if counter > 60
  end
end

Given(/^the user lowercases "([^"]*)" concepts$/) do |which_concepts|
  page.all(:xpath, "//input[contains(@id,'concept_4_')]").each do |concept_field|
    next unless ('all'.eql? which_concepts) || rand(2).positive?

    text = concept_field.value
    text.length.times do
      concept_field.send_keys :delete
    end
    concept_field.set concept_field.value.downcase
  end
end

Given(/^the user assigns "([^"]*)" feedback to all candidates$/) do |feedback_type|
  wait_for_render
  # Enable max rows
  max_rows = @bingo.candidates.size
  page.find(:xpath, "//div[@id='pagination-rows']").click
  page.find(:xpath, "//li[text()='#{max_rows}']").click

  concept_count = Concept.count
  concepts = if concept_count < 2
               []
             else
               Concept.where('id > 0').collect(&:name)
             end

  concept_count.upto(concept_count + 3) do |counter|
    concepts << "concept #{counter}"
  end

  feedbacks = CandidateFeedback.unscoped.where('name_en like ?', "#{feedback_type}%")
  error_msg = ''
  @feedback_list = {}
  @bingo.candidates.completed.each do |candidate|
    feedback = feedbacks.sample
    @feedback_list[candidate.id] = { feedback: }
    concept = nil
    if feedback.critique == 'term_problem'
      @feedback_list[candidate.id][:concept] = ''
    else
      concept = concepts.rotate!(1).first
      @feedback_list[candidate.id][:concept] = concept.split.map(&:capitalize).*' '
    end

    begin
      retries ||= 0
      elem = page.find(:xpath,
                       "//div[@id='feedback_4_#{candidate.id}']")
      elem.scroll_to(elem)
      elem.click
    rescue Selenium::WebDriver::Error::ElementNotInteractableError => e
      elem.send_keys :escape
      (retries += 1).should be < 20, 'Too many retries'
      retry unless retries > 5
    end

    begin
      elem = page.find(:xpath,
                       "//li[text()=\"#{feedback.name}\"]")
      elem.scroll_to(elem)
      elem.send_keys :enter

      if concept.present?
        elem = page.find(:xpath, "//input[@id='concept_4_#{candidate.id}']")
        elem.scroll_to(elem)
        elem.set(concept)
      end
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
      elem = page.find(:xpath,
                       "//li[text()=\"#{feedback.name}\"]")
      elem.scroll_to(elem)
      elem.click

      error_msg += "FAIL\tFeedback: #{feedback.name} for #{candidate.id}" unless retries.positive?
      error_msg += e.message
      error_msg += "\t\t#{candidate.inspect}" unless retries.positive?
      # elem.send_keys :escape

      (retries += 1).should be < 20, 'Too many retries'
      retry unless retries > 5
    rescue Capybara::ElementNotFound => e
      error_msg += "FAIL\tFeedback: #{feedback.name} for #{candidate.id}" unless retries.positive?
      error_msg += e.message
      error_msg += "\t\t#{candidate.inspect}" unless retries.positive?
      elem.send_keys :enter
    end
  end
end

Given(/^the saved reviews match the list$/) do
  @feedback_list.each do |key, value|
    Candidate.find(key).concept.name.should eq value[:concept] if value[:concept].present?
  end
end

Given(/^the user checks "([^"]*)"$/) do |checkbox_name|
  find(:xpath, "//*[text()='#{checkbox_name}']").click
end

Given(/^the user is the most recently created user$/) do
  @user = @users.last
end

When(/^the user clicks the link to the candidate review$/) do
  wait_for_render
  step 'the user switches to the "Task View" tab'
  find(:xpath, "//div[text()='#{@bingo.get_name(@anon)}']").click

  wait_for_render
  # Enable max rows
  max_rows = @bingo.candidates.size
  page.find(:xpath, "//div[@id='pagination-rows']").click
  page.find(:xpath, "//li[text()='#{max_rows}']").click
end

Then(/^there will be (\d+) concepts$/) do |concept_count|
  # Adjusting for an entry for the seeded '*' concept
  Concept.count.should eq(concept_count.to_i + 1)
end

Then('the user navigates home') do
  find(:xpath, '//*[@id="main-menu-button"]').click
  find(:xpath, '//*[@id="home-menu-item"]').click
end

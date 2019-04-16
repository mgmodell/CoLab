# frozen_string_literal: true

Given /^the users "([^"]*)" prep "([^"]*)"$/ do |completion_level, group_or_solo|
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

      accept_alert do
        if !collab_requested
          step 'the user requests collaboration'
          collab_requested = true
        else
          step 'the user "accepts" the collaboration request'
        end
      end

      step 'the user logs out'
    end
    user_group = [@users.sample]
  end

  @user = @users.sample
  step 'the user "has" had demographics requested'
  step 'the user logs in'
  step 'the user clicks the link to the candidate list'
  fields = page.all(:xpath, "//input[contains(@id, '_term')]").count
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
    puts "we didn't test anything here: " + completion_level
  end

  user_group.each do |user|
    @user = user
    step 'the user "has" had demographics requested'
    step 'the user logs in'
    step 'the user clicks the link to the candidate list'
    step "the user populates #{fields_to_complete} of the \"term\" entries"
    step "the user populates #{fields_to_complete} of the \"definition\" entries"
    step 'the user clicks "Save"'
    step 'the user will see "success"'
    step 'the user logs out'
  end

  # Reset back to previous user (whomever that was)
  @user = temp_user
end

Then /^the user sees (\d+) candidate items for review$/ do |candidate_count|
  page.all(:xpath, "//select[contains(@id, 'feedback_4_')]")
      .count.should eq candidate_count.to_i
  # Latest UI only shows 'Concept' when relevant/available
  # page.all(:xpath, "//input[contains(@id, 'concept_4_')]")
  #    .count.should eq candidate_count.to_i
end

Given /^the user sees review items for all the expected candidates$/ do
  @bingo.candidates.completed.each do |candidate|
    # Latest UI only shows 'Concept' when relevant/available
    # page.all(:xpath, "//input[@id='concept_4_#{candidate.id}']").count.should eq 1
    page.all(:xpath,
             "//select[@id='feedback_4_#{candidate.id}']",
             visible: false).count.should eq 1
  end
end

Then /^the user waits while seeing "([^"]*)"$/ do |wait_msg|
  counter = 0
  while page.has_text? wait_msg
    sleep 1
    counter += 1
    break if counter > 60
  end
end

Given /^the user lowercases "([^"]*)" concepts$/ do |which_concepts|
  page.all(:xpath, "//input[contains(@id,'concept_4_')]").each do |concept_field|
    puts "Val: #{concept_field.value} lcase: #{concept_field.value.downcase}"

    if ( ( 'all'.eql? which_concepts ) || ( rand( 2 ) > 0 ) )
      text = concept_field.value
      text.length.times do
        concept_field.send_keys :delete
      end
      concept_field.set concept_field.value.downcase
    end
  end
end

Given /^the user assigns "([^"]*)" feedback to all candidates$/ do |feedback_type|
  concept_count = Concept.count
  concepts = concept_count < 2 ? [] :
              Concept.where('id > 0').collect(&:name)

  concept_count.upto (concept_count + 3) do |counter|
    concepts << 'concept ' + counter.to_s
  end

  feedbacks = CandidateFeedback.unscoped.where('name_en like ?', feedback_type + '%')
  @feedback_list = {}
  @bingo.candidates.completed.each do |candidate|
    feedback = feedbacks.sample
    @feedback_list[candidate.id] = { feedback: feedback }
    concept = nil
    if feedback.name.start_with? 'Term'
      @feedback_list[candidate.id][:concept] = ''
    else
      concept = concepts.rotate!(1).first
      @feedback_list[candidate.id][:concept] = concept.split.map(&:capitalize).*' '
    end
    page.find(:xpath,
              "//select[@id='feedback_4_#{candidate.id}']",
              visible: :all).click
    page.find(:xpath,
              "//select[@id='feedback_4_#{candidate.id}']//option[@value='#{feedback.id}']",
              visible: :all).click
    unless concept.blank?
      page.find(:xpath, "//input[@id='concept_4_#{candidate.id}']")
          .set(concept)
    end
  end
end

Given /^the saved reviews match the list$/ do
  @feedback_list.each do |key, value|
    Candidate.find(key).candidate_feedback_id.should eq value[:feedback][:id]
    Candidate.find(key).concept.name.should eq value[:concept] unless value[:concept].blank?
  end
end

Given /^the user checks "([^"]*)"$/ do |checkbox_name|
  all(:xpath, "//div[contains(.,'#{checkbox_name}')]").last.click
end

Given /^the user is the most recently created user$/ do
  @user = @users.last
end

When /^the user clicks the link to the candidate review$/ do
  first(:link, @bingo.get_name(@anon)).click
  # click_link_or_button @bingo.get_name(@anon)
end

Then /^there will be (\d+) concepts$/ do |concept_count|
  # Adjusting for an entry for the seeded '*' concept
  Concept.count.should eq ( concept_count.to_i + 1)
end

Then('the user navigates to {string}') do |location|
  click_link_or_button location
end

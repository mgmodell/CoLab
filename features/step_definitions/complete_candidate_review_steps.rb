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

  @user = @users.sample unless @user.present?
  step 'the user "has" had demographics requested'
  step 'the user logs in'
  step 'the user clicks the link to the candidate list'
  fields = page.all(:xpath, "//input[contains(@id, '_term')]").count
  step 'the user logs out'

  # set up how much we want to complete
  case completion_level
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

Then /^the user sees (\d+) candidate items for review$/  do |candidate_count|
  page.all(:xpath, "//select[contains(@id, 'candidate_feedback')]")
      .count.should eq candidate_count.to_i
  page.all(:xpath, "//input[contains(@id, 'concept')]")
      .count.should eq candidate_count.to_i
end

Given /^the user sees review items for all the expected candidates$/ do
  @bingo.candidates.completed.each do |candidate|
    page.all(:xpath, "//select[@id='_bingo_candidates_review_#{@bingo.id}_candidate_feedback_#{candidate.id}']").count.should eq 1
    page.all(:xpath, "//input[@id='_bingo_candidates_review_#{@bingo.id}_concept_#{candidate.id}']").count.should eq 1
  end
end

Given /^the user assigns "([^"]*)" feedback to all candidates$/ do |feedback_type|
  concepts = ['concept 1', 'concept 2', 'concept 3', 'concept 4']
  feedbacks = CandidateFeedback.where('name like ?', feedback_type + '%')
  @feedback_list = {}
  @bingo.candidates.completed.each do |candidate|
    feedback = feedbacks.sample
    @feedback_list[candidate.id] = { feedback: feedback }
    concept = nil
    if feedback.name.start_with? 'Term'
      @feedback_list[candidate.id][:concept] = ''
    else
      concept = concepts.rotate!(1).first
      @feedback_list[candidate.id][:concept] = concept
    end
    unless concept.nil?
      page.find(:xpath, "//input[@id='_bingo_candidates_review_#{@bingo.id}_concept_#{candidate.id}']")
          .set(concept)
    end
    page.find(:xpath, "//select[@id='_bingo_candidates_review_#{@bingo.id}_candidate_feedback_#{candidate.id}']")
        .find(:xpath, "option[@value='#{feedback.id}']").select_option
  end
end

Given /^the saved reviews match the list$/ do
  @feedback_list.each do |key, value|
    Candidate.find(key).candidate_feedback_id.should eq value[:feedback][:id]
    Candidate.find(key).concept.name.should eq value[:concept] unless value[:concept].blank?
  end
end

Given /^the user checks "([^"]*)"$/ do |checkbox_name|
  check(checkbox_name)
end

Given /^the user is the most recently created user$/ do
  @user = @users.last
end

When /^the user clicks the link to the candidate review$/ do
  click_link_or_button 'Review: ' + @bingo.name
end

Then /^there will be (\d+) concepts$/ do |concept_count|
  Concept.count.should eq concept_count.to_i
end

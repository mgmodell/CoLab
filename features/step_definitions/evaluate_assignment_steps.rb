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
      creator: user,
      submitted:,
      recorded_score: nil
    )
    submission.save
    submission.errors.size.should be(0), submission.errors.full_messages
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
  inplace_path = "//div[text()='Click here to see the submissions list']" 
  find(:xpath, inplace_path ).click if has_xpath?( inplace_path )

  row = find_all( :xpath, "//table/tbody/tr" )[index - 1]
  row.click
  row.find_all(:xpath, "td" )[0]

  submission_id = row.text.to_i
  @submission = Submission.find submission_id
  @submission.should be_present
  wait_for_render
end

Then('the user hides all but the {string} tab') do |tabname|
  tabs = find_all(:xpath, "//div[@role='group']/button[not(text()='#{tabname}') and @aria-pressed='true']" )
  tabs.each(&:click)
  tabs = find_all(:xpath, "//div[@role='group']/button[text()='#{tabname}' and @aria-pressed='false']" )
  tabs.each(&:click)
end

Then('the contents match the submission contents') do
  find_all(:xpath, "//p[@id='sub_link']/a[@href='#{@submission.sub_link}']").size.should be 1
  find_all(:xpath, "//p[@id='sub_text' and contains(.,'#{@submission.sub_text}')]").size.should be 1
end

Then('the user enters overall feedback') do
  editor = find(:xpath, "//div[@id='overall-feedback']/div[@data-pc-section='content']" )
  editor.click

  send_keys :end
  editor.text.length.times do
    send_keys :backspace
  end

  fb_text_db = ''

  rand(2..7).times do
    para = Faker::Lorem.paragraph
    fb_text_db += "<p>#{para}</p>" if para.length.positive?
    send_keys para, :enter
  end

  # send_keys sub_text_web, :backspace
  send_keys :backspace
  if @submission_feedback.present?
    @submission_feedback.feedback = fb_text_db
  else
    @submission_feedback = SubmissionFeedback.new(
      feedback: fb_text_db
    )
  end

end

Then('the user responds to all criteria with {string} and {string} feedback') do |competence, completeness|
  wait_for_render

  has_empty = false
  @assignment.rubric.criteria.each do |criterium|
    has_xpath? "//div[@id='description-#{criterium.id}']/div[@data-pc-section='content']"
    #TODO fix to make sure at least one is empty
    feedback = ''
    case completeness
    when 'all'
      feedback = Faker::Lorem.paragraph
    when 'some'
      if rand( 3 ) > 0
        has_empty = true
      else
        feedback = Faker::Lorem.paragraph 
      end
    when 'no', 'none'
      # Nothing should be entered
    else
      log "No such completeness level: #{completeness}"
      pending
    end
    feedback_elem = find( :xpath, "//div[@id='feedback-#{criterium.id}']/div[@data-pc-section='content']" )

    feedback_elem.click
    send_keys [:command, 'a'], :backspace
    send_keys [:control, 'a'], :backspace
    send_keys :end
    feedback_elem.text.size.times do
      send_keys :backspace
    end
    send_keys feedback
    feedback = "<p>#{feedback}</p>" if feedback.length.positive?

    score = 0
    case competence
    when 'proficient'
      level_elements = find_all(:xpath, "//td[contains(@id,'level-#{criterium.id}')]")
      proficient_elem = find(:xpath, "//td[contains(@id,'level-#{criterium.id}-#{level_elements.size}')]")
      proficient_elem.click
      score = 100
    when 'competent'
      level_elements = find_all(:xpath, "//td[contains(@id,'level-#{criterium.id}')]")
      competent_level = level_elements.size > 1 ? level_elements.size - 1 : 1
      competent_elem = find(:xpath, "//td[contains(@id,'level-#{criterium.id}-#{competent_level}')]")
      competent_elem.click
      score = ( (competent_level) * 100.0 / level_elements.size).round
    when 'novice'
      elem = find(:xpath, "//td[@id='minimum-#{criterium.id}']")
      elem.click
      score = 0
    when 'numbers', 'mixed'
      elem = find(:xpath, "//input[@id='score-#{criterium.id}']")
      elem.click
      score = rand(100)
      elem.set score
    else
      log "No such competence level: #{competence}"
      pending
    end

    score = score.round

    rubric_row_feedback = @submission_feedback.rubric_row_feedbacks.find {|rrf| rrf.criterium_id == criterium.id }

    if rubric_row_feedback.nil? 
      rubric_row_feedback = RubricRowFeedback.new(
        criterium:,
        feedback:,
        score:
      )
    else
      rubric_row_feedback.feedback = feedback
      rubric_row_feedback.score = score
    end
    @submission_feedback.rubric_row_feedbacks << rubric_row_feedback
  end
end

Then('the user saves the critique') do
  ack_messages
  click_button 'save_feedback'
  wait_for_render
end

Then('the db critique matches the data entered') do
  SubmissionFeedback.where( submission_id: @submission.id ).size.should be 1
  submission_feedback = SubmissionFeedback.where( submission_id: @submission.id ).take
  #Check the submissionFeedback contents
  @submission_feedback.feedback.should eq submission_feedback.feedback

  @submission_feedback.rubric_row_feedbacks.each do |rrfbk|
    db_rrfbks = RubricRowFeedback.where(
      submission_feedback_id: submission_feedback.id,
      criterium_id: rrfbk.criterium_id
    )
    db_rrfbks.size.should eq 1
    rrfbk.score.should eq db_rrfbks[0].score
    if rrfbk.feedback.blank?
      db_rrfbks[0].feedback.should be_blank
    else  
      rrfbk.feedback.should eq db_rrfbks[0].feedback
    end
  end
end

Then('the user selects the {string} submission') do |temporal_relation|
  inplace_path = "//div[text()='Click here to see the submissions list']" 
  find(:xpath, inplace_path ).click if has_xpath?( inplace_path )

  id_col = 0
  target_col = 0

  find_all( :xpath, '//th').each_with_index do |th, index|
    target_col = index + 1 if 'Submission date' == th.text
    id_col = index + 1 if 'Submission id' == th.text
  end

  find( :xpath, "//th[#{id_col }]" ).click

  row_index = 1
  case temporal_relation
  when 'latest'
    find( :xpath, "//th[#{target_col }]" ).click
    find( :xpath, "//th[#{target_col }]" ).click
  when 'earliest'
    find( :xpath, "//th[#{target_col }]" ).click
  else
    log "Selecting the '#{temporal_relation}' item is not yet handled"
    pending
  end

  id_cell = find(:xpath, "//table/tbody/tr[#{row_index}]/td[#{id_col}]" )
  submission_id = id_cell.text.to_i
  @submission = Submission.find submission_id
  id_cell.click

  wait_for_render
end

Then('the user sets score to {int}') do |score|
  label_txt = 'Override the score?'
  find( :xpath, "//label[contains(.,'#{label_txt}')]").click
  find( :xpath, '//input[@id="override-score"]').click
  send_keys score
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
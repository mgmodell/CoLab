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
  editor = find(:xpath, "//div[@class='rdw-editor-main' and contains(.,'Overall feedback')]")
  editor.click

  fb_text_web = ''
  fb_text_db = ''

  rand(2..7).times do
    para = Faker::Lorem.paragraph
    fb_text_db += "<p>#{para}</p>"
    send_keys para, :enter
    fb_text_web += "#{para}\n"
  end
  # send_keys sub_text_web, :backspace
  send_keys :backspace
  @submission_feedback = SubmissionFeedback.new(
    feedback: fb_text_db

  )

end

Then('the user responds to all criteria with {string} and {string} feedback') do |competence, completeness|
  wait_for_render

  has_empty = false
  @assignment.rubric.criteria.each do |criterium|
    has_xpath? "//div[@id='description-#{criterium.id}' and contains(.,'#{criterium.description}')]"
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
    feedback_elem = find( :xpath, "//div[@id='feedback-#{criterium.id}']//div[contains(@class,'rdw-editor-main')]")
    feedback_elem.click
    send_keys feedback
    feedback = "<p>#{feedback}</p>"

    score = 0
    case competence
    when 'proficient'
      level_elements = find_all(:xpath, "//div[contains(@id,'level-#{criterium.id}')]")
      proficient_elem = find(:xpath, "//div[contains(@id,'level-#{criterium.id}-#{level_elements.size}')]")
      proficient_elem.click
      score = 100
    when 'competent'
      level_elements = find_all(:xpath, "//div[contains(@id,'level-#{criterium.id}')]")
      competent_level = level_elements.size > 1 ? level_elements.size - 1 : 1
      competent_elem = find(:xpath, "//div[contains(@id,'level-#{criterium.id}-#{competent_level}')]")
      competent_elem.click
      score = (competent_level) * 100 / level_elements.size
    when 'novice'
      elem = find(:xpath, "//div[@id='minimum-#{criterium.id}']")
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
  @submission_feedback.feedback.should eq submission_feedback.feedback.gsub( "\n", '' )
  @submission_feedback.calculated_score.should eq submission_feedback.calculated_score

  @submission_feedback.rubric_row_feedbacks.each do |rrfbk|
    db_rrfbks = RubricRowFeedback.where(
      submission_feedback_id: submission_feedback.id,
      criterium_id: rrfbk.criterium_id
    )
    db_rrfbks.size.should eq 1
    rrfbk.score.should eq db_rrfbks[0].score
    rrfbk.feedback.should eq db_rrfbks[0].feedback.gsub( "\n", '' )

  end
end

Then('the user selects the {string} submission') do |temporal_relation|
  find(:xpath, '//div[contains(@class,"MuiDataGrid-columnHeaderTitleContainer") and contains(.,"Submission date")]' \
                '//button[@title="Sort"]', visible: :all).hover

  case temporal_relation
  when 'latest'
    sort_dir = 'Downward'
  else
    log "Selecting the '#{temporal_relation}' item is not yet handled"
    pending
  end
  svg_search = "//div[contains(@class,'MuiDataGrid-columnHeaderTitleContainer') and contains(.,'Submission date')]" \
                "//button[@title='Sort']/*[contains(@data-testid,'#{sort_dir}')]"

  unless has_xpath? svg_search
    find(:xpath, "//div[contains(@class,'MuiDataGrid-columnHeaderTitleContainer') and contains(.,'Submission date')]" +
                  "//button[@title='Sort']", visible: :all).click
    unless has_xpath? svg_search
      find(:xpath, "//div[contains(@class,'MuiDataGrid-columnHeaderTitleContainer') and contains(.,'Submission date')]" +
                    "//button[@title='Sort']", visible: :all).click
    end
    true.should eq false unless has_xpath? svg_search
  end
  find(:xpath, '//div[@data-rowindex=0]').click

  row = find(:xpath, '//div[@data-rowindex=0]')
  row.click
  submission_id = row['data-id'].to_i
  @submission = Submission.find submission_id

  wait_for_render
end

Then('the user sets score to {int}') do |score|
  click_link_or_button 'Override the score?'
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
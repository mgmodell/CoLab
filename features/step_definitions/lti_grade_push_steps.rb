# frozen_string_literal: true

require 'webmock'
include WebMock::API

# ---------------------------------------------------------------------------
# Setup helpers
# ---------------------------------------------------------------------------

# Stub all external HTTP calls that the LtiConnection model makes when
# pushing grades. The step "Given the LMS grade push endpoint is available"
# must be called before any grade-push scenario so that:
#   1. The OAuth2 token endpoint returns a synthetic bearer token.
#   2. The AGS scores endpoint returns 200 OK.
#
# WebMock is configured here; since Capybara runs the Rails app in the same
# OS process (just a different thread), Net::HTTP stubs are shared across
# threads and will intercept calls made from the Rails server thread.
Given( 'the LMS grade push endpoint is available' ) do
  WebMock.enable!
  WebMock.disable_net_connect!( allow_localhost: true )

  # Stub the OAuth2 token endpoint.
  stub_request( :post, 'https://lms.example.com/login/oauth2/token' )
    .to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { access_token: 'test-bearer-token-12345', token_type: 'Bearer', expires_in: 3600 }.to_json
    )

  # Stub the AGS scores endpoint (matches any line item).
  stub_request( :post, %r{https://lms\.example\.com/api/lti/line_items/\d+/scores} )
    .to_return( status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' } )
end

After do
  WebMock.reset!
  WebMock.disable!
  WebMock.allow_net_connect!
end

# ---------------------------------------------------------------------------
# Background / DB setup
# ---------------------------------------------------------------------------

Given( 'the bingo game has an LTI connection configured' ) do
  @bingo.reload
  @bingo.build_lti_connection(
    line_item_url: 'https://lms.example.com/api/lti/line_items/1',
    ags_access_token_url: 'https://lms.example.com/login/oauth2/token',
    client_id: 'client-abc-123',
    deployment_id: 'deploy-001',
    iss: 'https://lms.example.com'
  ).save!
end

Given( 'the experience has an LTI connection configured' ) do
  @experience.reload
  @experience.build_lti_connection(
    line_item_url: 'https://lms.example.com/api/lti/line_items/10',
    ags_access_token_url: 'https://lms.example.com/login/oauth2/token',
    client_id: 'exp-client-789',
    deployment_id: 'deploy-exp-001',
    iss: 'https://lms.example.com'
  ).save!
end

Given( 'the project has an LTI connection configured' ) do
  @project.reload
  @project.build_lti_connection(
    line_item_url: 'https://lms.example.com/api/lti/line_items/20',
    ags_access_token_url: 'https://lms.example.com/login/oauth2/token',
    client_id: 'proj-client-456',
    deployment_id: 'deploy-proj-001',
    iss: 'https://lms.example.com'
  ).save!
end

Then( 'completing the candidate review queues an LTI grade push' ) do
  previous_count = lti_grade_push_job_count

  @bingo.update!( reviewed: true )

  lti_grade_push_job_count.should eq( previous_count + 1 )
end

Given( 'a linked LTI assignment submission exists' ) do
  rubric = Rubric.new( name: 'LTI Cucumber rubric', school: @user.school, user: @user )
  rubric.save!( validate: false )
  @lti_assignment = Assignment.new(
    course: @course,
    rubric:,
    name: 'LTI Cucumber assignment',
    start_date: Time.current,
    end_date: 1.day.from_now
  )
  @lti_assignment.save!( validate: false )

  student = @course.enrolled_students.first
  @lti_submission = Submission.new(
    assignment: @lti_assignment,
    user: student,
    creator: student,
    rubric:,
    submitted: Time.current,
    sub_text: 'Submitted assignment'
  )
  @lti_submission.save!( validate: false )

  deployment = LtiDeployment.create!(
    issuer: 'https://lms.example.com',
    client_id: "cucumber-client-#{@lti_assignment.id}",
    auth_login_url: 'https://lms.example.com/login',
    auth_token_url: 'https://lms.example.com/login/oauth2/token',
    key_set_url: 'https://lms.example.com/jwks'
  )
  LtiResourceLink.create!(
    lti_deployment: deployment,
    assignment: @lti_assignment,
    resource_link_id: "cucumber-assignment-#{@lti_assignment.id}",
    line_item_url: 'https://lms.example.com/api/lti/line_items/30'
  )
end

Then( 'grading the assignment submission queues an LTI grade push' ) do
  previous_count = lti_grade_push_job_count

  @lti_submission.update!( recorded_score: 85 )

  lti_grade_push_job_count.should eq( previous_count + 1 )
end

Given( 'the project has an ended assessment' ) do
  @project.update_columns( active: true )
  @ended_assessment = Assessment.new(
    project: @project,
    start_date: 2.days.ago,
    end_date: 1.day.ago,
    active: true,
    instructor_updated: false
  )
  @ended_assessment.save!( validate: false )
end

Given( 'the course has an ended experience' ) do
  @ended_experience = Experience.new(
    course: @course,
    name: 'Ended LTI Cucumber experience',
    start_date: 3.days.ago,
    end_date: 2.days.ago,
    student_end_date: 1.day.ago,
    instructor_updated: false
  )
  @ended_experience.save!( validate: false )
end

Then( 'the hourly reminder sweep queues its LTI grade push' ) do
  previous_count = lti_grade_push_job_count

  LtiGradePushJob.enqueue_ended_period_grades

  lti_grade_push_job_count.should eq( previous_count + 1 )
end

def lti_grade_push_job_count
  adapter = ActiveJob::Base.queue_adapter
  [adapter.enqueued_jobs, adapter.performed_jobs].sum do | jobs |
    jobs.count { | job | job[:job] == LtiGradePushJob }
  end
end

# ---------------------------------------------------------------------------
# UI assertions
# ---------------------------------------------------------------------------

Then( 'the user sees the LTI connection status is {string}' ) do | status_text |
  wait_for_render
  should have_css( "[data-pc-name='tag']", text: status_text )
end

Then( 'the user clicks {string} and confirms the grade push dialog' ) do | link_or_button |
  wait_for_render

  if has_xpath?( %Q{//button[contains(.,'#{link_or_button}')]},
                 visible: :all )
    btn = find( :xpath, %Q{//button[contains(.,'#{link_or_button}')]},
                match: :first,
                visible: :all )
  elsif has_xpath?( %Q{//a[contains(.,'#{link_or_button}')]},
                    visible: :all )
    btn = find( :xpath, %Q{//a[contains(.,'#{link_or_button}')]},
                visible: :all )
  elsif has_xpath?( %Q{//input[@value='#{link_or_button}']},
                    visible: :all )
    btn = find( :xpath, %Q{//input[@value='#{link_or_button}']},
                visible: :all )
  else
    puts "nothing found yet for '#{link_or_button}"
    pending # nothing is found yet
  end
  begin
    retries ||= 0
    btn.click
    page.driver.browser.switch_to.alert.accept
  rescue NoMethodError => e
    puts e.inspect
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
    puts e.inspect
    if ( retries += 1 ) < 4
      retry
    else
      true.should be false
    end
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      sleep 0.5
      page.driver.browser.switch_to.alert.accept
  end
  wait_for_render
end

Then( 'the {string} button is disabled' ) do | button_label |
  wait_for_render
  btn = find( :xpath, %Q{//button[contains(.,'#{button_label}')]}, visible: :all )
  btn['disabled'].should_not be_nil
end

# ---------------------------------------------------------------------------
# DB assertions
# ---------------------------------------------------------------------------

Then( 'the lti connection for the bingo game has {string} of {string}' ) do | field, value |
  @bingo.reload
  connection = @bingo.lti_connection
  connection.should_not be_nil
  connection.send( field ).should eq value
end

Then( 'the lti connection for the experience has {string} of {string}' ) do | field, value |
  @experience.reload
  connection = @experience.lti_connection
  connection.should_not be_nil
  connection.send( field ).should eq value
end

Then( 'the lti connection for the project has {string} of {string}' ) do | field, value |
  @project.reload
  connection = @project.lti_connection
  connection.should_not be_nil
  connection.send( field ).should eq value
end

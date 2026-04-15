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

# ---------------------------------------------------------------------------
# UI assertions
# ---------------------------------------------------------------------------

Then( 'the user sees the LTI connection status is {string}' ) do | status_text |
  wait_for_render
  should have_css( "[data-pc-name='tag']", text: status_text )
end

Then( 'the user confirms the grade push dialog' ) do
  # The LtiConnectionPanel uses window.confirm before pushing grades.
  begin
    page.driver.browser.switch_to.alert.accept
  rescue Selenium::WebDriver::Error::NoSuchAlertError
    sleep 0.5
    page.driver.browser.switch_to.alert.accept
  end
  wait_for_render
end

Then( 'the {string} button is disabled' ) do | button_label |
  wait_for_render
  btn = find( :xpath, "//button[contains(.,'#{button_label}')]", visible: :all )
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

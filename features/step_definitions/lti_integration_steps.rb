# frozen_string_literal: true

require 'json'

# ── Dynamic Registration steps ────────────────────────────────────────────────

When('the LMS requests the LTI tool configuration') do
  visit '/lti/tool_connect'
  @response_body = JSON.parse(page.body)
end

Then('the response contains a valid LTI 1.3 tool configuration') do
  @response_body.should be_a(Hash)
  @response_body['application_type'].should eq 'web'
end

Then('the tool configuration has a login URI') do
  @response_body['initiate_login_uri'].should be_present
end

Then('the tool configuration has a launch URI') do
  lti_config = @response_body['https://purl.imsglobal.org/spec/lti-tool-configuration']
  lti_config.should be_present
  lti_config['target_link_uri'].should be_present
end

Then('the tool configuration has a JWKS URI') do
  @response_body['jwks_uri'].should be_present
end

# ── JWKS steps ────────────────────────────────────────────────────────────────

When('the platform requests the JWKS endpoint') do
  visit '/.well-known/jwks.json'
  @response_body = JSON.parse(page.body)
end

Then('the response contains a JSON key set with at least one key') do
  @response_body['keys'].should be_an(Array)
  @response_body['keys'].should_not be_empty
end

# ── OIDC Login steps ──────────────────────────────────────────────────────────

Given('a registered LTI deployment exists for issuer {string}') do |issuer|
  @deployment = LtiDeployment.find_by(issuer: issuer)
  if @deployment.nil?
    @deployment = LtiDeployment.create!(
      issuer: issuer,
      client_id: "bdd_client_#{SecureRandom.hex(4)}",
      auth_login_url: "#{issuer}/auth",
      auth_token_url: "#{issuer}/token",
      key_set_url: "#{issuer}/jwks"
    )
  end
end

When('the platform initiates login for issuer {string}') do |issuer|
  deployment = LtiDeployment.find_by(issuer: issuer)
  params = {
    iss: issuer,
    login_hint: 'bdd_user_42',
    target_link_uri: 'http://www.example.com/lti/launch'
  }
  params[:client_id] = deployment.client_id if deployment
  page.driver.get("/lti/login?#{params.to_query}")
  @last_response_status = page.status_code
  @last_redirect_location = page.response_headers['Location'] || page.response_headers['location'] || ''
end

Then('the response redirects to the platform authorization endpoint') do
  @last_response_status.should eq 302
end

Then('the redirect contains state and nonce parameters') do
  @last_redirect_location.should include('nonce=')
  @last_redirect_location.should include('state=')
end

# ── Generic status step ───────────────────────────────────────────────────────

Then('the response status is {int}') do |status|
  @last_response_status.should eq status
end

# ── Launch steps ──────────────────────────────────────────────────────────────

When('a launch request is sent without an id_token') do
  page.driver.post('/lti/launch', state: 'some_state')
  @last_response_status = page.status_code
end

# ── NRPS steps ────────────────────────────────────────────────────────────────

When('the NRPS sync is requested for a non-existent resource link') do
  page.driver.post('/lti/names_roles/999999')
  @last_response_status = page.status_code
end

# ── AGS steps ─────────────────────────────────────────────────────────────────

When('the AGS grade push is requested for a non-existent resource link') do
  page.driver.post('/lti/grades/999999')
  @last_response_status = page.status_code
end

# ── Model validation steps ────────────────────────────────────────────────────

Given('a new LTI deployment with all required fields') do
  @deployment = LtiDeployment.new(
    issuer: "https://bdd-platform-#{SecureRandom.hex(4)}.example.com",
    client_id: "bdd_client_#{SecureRandom.hex(4)}",
    auth_login_url: 'https://bdd-platform.example.com/auth',
    auth_token_url: 'https://bdd-platform.example.com/token',
    key_set_url: 'https://bdd-platform.example.com/jwks'
  )
end

Then('the deployment is valid and persisted') do
  @deployment.valid?.should be true
  @deployment.save.should be true
  @deployment.persisted?.should be true
end

Given('a resource link for that deployment with resource_link_id {string}') do |rl_id|
  @resource_link = LtiResourceLink.new(
    lti_deployment: @deployment,
    resource_link_id: rl_id
  )
end

Then('the resource link is valid') do
  @resource_link.valid?.should be true
end

Then('the resource link belongs to the deployment') do
  @resource_link.lti_deployment.should eq @deployment
end

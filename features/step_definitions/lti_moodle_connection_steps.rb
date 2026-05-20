# frozen_string_literal: true

require 'json'
require 'webmock'
include WebMock::API

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Submit a form to /lti/simulate_launch via JavaScript so that the full
# Capybara Selenium browser session (including cookies / Devise session) is
# used.  This lets Cucumber scenarios drive the LTI resource-link and
# deep-linking flows without a live Moodle instance or real JWT signing.
def simulate_lti_launch( iss:, message_type: 'LtiResourceLinkRequest', **extra )
  # Ensure we are on a real page (not about:blank) before running execute_script.
  visit '/' if current_url !~ %r{\Ahttps?://}

  fields = { iss: iss, message_type: message_type }.merge( extra )
  field_js = fields.map do | k, v |
    "addField(#{k.to_s.to_json}, #{v.to_s.to_json});"
  end.join( "\n    " )

  page.execute_script( <<~JS )
    (function() {
      var form = document.createElement('form');
      form.method = 'POST';
      form.action = '/lti/simulate_launch';
      function addField(name, value) {
        var input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        form.appendChild(input);
      }
      #{field_js}
      document.body.appendChild(form);
      form.submit();
    })();
  JS

  wait_for_render
end

After do
  WebMock.reset!
  WebMock.disable!
  WebMock.allow_net_connect!
end

# ---------------------------------------------------------------------------
# Dynamic Registration
# ---------------------------------------------------------------------------

When( 'the user visits the CoLab LTI Dynamic Registration URL' ) do
  visit '/lti/tool_connect.json'
end

Then( 'the LTI tool configuration is returned' ) do
  body_text = begin
    find( 'pre', wait: 1 ).text
  rescue Capybara::ElementNotFound
    page.body
  end
  @lti_config = JSON.parse( body_text )
  @lti_config.should be_a( Hash )
  @lti_config['application_type'].should eq 'web'
end

Then( 'the LTI tool configuration includes an OIDC login URI' ) do
  @lti_config['initiate_login_uri'].should be_present
end

Then( 'the LTI tool configuration includes a launch redirect URI' ) do
  @lti_config['redirect_uris'].should be_present
  @lti_config['redirect_uris'].should_not be_empty
end

Then( 'the LTI tool configuration includes a JWKS URI' ) do
  @lti_config['jwks_uri'].should be_present
end

Then( 'the LTI tool configuration advertises Deep Linking support' ) do
  lti_tool_config = @lti_config['https://purl.imsglobal.org/spec/lti-tool-configuration']
  lti_tool_config.should be_present
  messages = lti_tool_config['messages'] || []
  messages.any? { | m | m['type'] == 'LtiDeepLinkingRequest' }.should be true
end

# ---------------------------------------------------------------------------
# Resource-link launch – course and enrolment linking
# ---------------------------------------------------------------------------

When( 'a Moodle LTI launch links the Moodle course {string} to the CoLab course' ) do | context_title |
  simulate_lti_launch(
    iss: @deployment.issuer,
    message_type: 'LtiResourceLinkRequest',
    resource_link_id: 'bdd_rl_course_link_001',
    course_id: @course.id,
    context_id: 'moodle_ctx_001',
    context_title: context_title,
    user_email: @user.email
  )
end

When( 'a Moodle instructor launches CoLab and links it to the CoLab course as {string}' ) do | email |
  simulate_lti_launch(
    iss: @deployment.issuer,
    message_type: 'LtiResourceLinkRequest',
    resource_link_id: 'bdd_rl_enrol_001',
    course_id: @course.id,
    context_id: 'moodle_ctx_enrol_001',
    context_title: 'Introduction to CoLab',
    user_email: email
  )
  sleep 0.5 # Wait for the previous launch to complete and the user to be provisioned before simulating the next launch.
end

Given( 'the Moodle course {string} is already linked to the CoLab course' ) do | context_title |
  deployment = @deployment || LtiDeployment.find_by( issuer: 'http://moodle:8080' )
  lrl = deployment.lti_resource_links.find_or_create_by!(
    resource_link_id: 'bdd_rl_enrol_001'
  ) do | rl |
    rl.context_id    = 'moodle_ctx_enrol_001'
    rl.context_title = context_title
    rl.course        = @course
  end
end

# ---------------------------------------------------------------------------
# Assertions – resource link
# ---------------------------------------------------------------------------

Then( 'the CoLab course has an LTI resource link from {string}' ) do | issuer |
  @course.reload
  deployment = LtiDeployment.find_by( issuer: issuer )
  deployment.should be_present
  deployment.lti_resource_links.where( course: @course ).should exist
end

Then( 'the LTI resource link records the Moodle context title {string}' ) do | context_title |
  deployment = LtiDeployment.find_by( issuer: 'http://moodle:8080' )
  rl = deployment.lti_resource_links.find_by( course: @course )
  rl.should be_present
  rl.context_title.should eq context_title
end

Then( 'the CoLab course has exactly {int} LTI resource link from {string}' ) do | count, issuer |
  @course.reload
  deployment = LtiDeployment.find_by( issuer: issuer )
  deployment.should be_present
  deployment.lti_resource_links.where( course: @course ).count.should eq count
end

# ---------------------------------------------------------------------------
# Assertions – enrolment
# ---------------------------------------------------------------------------

Then( 'the user {string} is enrolled in the CoLab course' ) do | email |
  user = User.joins( :emails ).find_by( emails: { email: email } )
  user.should be_present
  Roster.find_by( user: user, course: @course ).should be_present
end

Then( 'the user {string} has the instructor role in the CoLab course' ) do | email |
  user = User.joins( :emails ).find_by( emails: { email: email } )
  roster = Roster.find_by( user: user, course: @course )
  roster.should be_present
  roster.role.should eq 'instructor'
end

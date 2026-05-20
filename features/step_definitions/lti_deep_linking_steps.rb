# frozen_string_literal: true

require 'webmock'
include WebMock::API

# ---------------------------------------------------------------------------
# Constants mirrored from LtiController for JWT inspection
# ---------------------------------------------------------------------------

LTI_DL_CONTENT_ITEMS = 'https://purl.imsglobal.org/spec/lti-dl/claim/content_items'

# ---------------------------------------------------------------------------
# Helper: trigger the deep-linking flow via simulate_launch
# ---------------------------------------------------------------------------

def trigger_deep_link_launch( issuer, return_url: 'http://moodle:8080/mod/lti/return.php' )
  # Ensure we are on a real page (not about:blank) before running execute_script.
  visit '/' if current_url !~ %r{\Ahttps?://}

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
      addField('iss',                   #{issuer.to_json});
      addField('message_type',          'LtiDeepLinkingRequest');
      addField('deep_link_return_url',  #{return_url.to_json});
      addField('context_id',            'bdd_dl_ctx_001');
      addField('context_title',         'BDD Moodle Course');
      addField('user_email',            #{@user.email.to_json});
      document.body.appendChild(form);
      form.submit();
    })();
  JS

  # wait_for_render won't work here because we're outside of 
  # our React app (PageWrapper). Therefore we use a simple sleep to 
  # give the server time to process the form submission and load the
  # new page.
  sleep 1 
end

After do
  WebMock.reset!
  WebMock.disable!
  WebMock.allow_net_connect!
end

# ---------------------------------------------------------------------------
# Deep-linking launch
# ---------------------------------------------------------------------------

When( 'a deep-linking LTI launch arrives from {string}' ) do | issuer |
  trigger_deep_link_launch( issuer )
end

# ---------------------------------------------------------------------------
# Content-selection page assertions
# ---------------------------------------------------------------------------

Then( 'the content-selection page is displayed' ) do
  wait_for_render
  page.should have_content( 'Select CoLab Content to Link' )
end

Then( 'the page lists the CoLab course with its bingo game' ) do
  page.should have_content( @course.get_name( false ) )
  page.should have_content( @bingo.get_topic( false ) )
end

Then( 'the page lists the CoLab course with its project' ) do
  page.should have_content( @course.get_name( false ) )
  page.should have_content( @project.get_name( false ) )
end

Then( 'the page lists the CoLab course with its experience' ) do
  page.should have_content( @course.get_name( false ) )
  page.should have_content( @experience.get_name( false ) )
end

# ---------------------------------------------------------------------------
# Activity selection
# ---------------------------------------------------------------------------

When( 'the instructor selects the bingo game for deep linking' ) do
  btn = find( :css, "button[aria-label='Select #{@bingo.get_topic( false )}']" )
  btn.click
  wait_for_render
end

When( 'the instructor selects the project for deep linking' ) do
  btn = find( :css, "button[aria-label='Select #{@project.get_name( false )}']" )
  btn.click
  wait_for_render
end

When( 'the instructor selects the experience for deep linking' ) do
  btn = find( :css, "button[aria-label='Select #{@experience.get_name( false )}']" )
  btn.click
  wait_for_render
end

# ---------------------------------------------------------------------------
# Deep-link response assertions
# ---------------------------------------------------------------------------

# In the test environment the auto-submit script is suppressed so the form
# stays in the DOM, letting us read and verify the JWT.
Then( 'a deep-linking response JWT is returned to Moodle' ) do
  wait_for_render
  jwt_input = find( 'input[name="JWT"]', visible: false )
  @dl_jwt_raw = jwt_input.value
  @dl_jwt_raw.should be_present

  # Decode without verification so we can inspect the payload
  @dl_payload = JWT.decode( @dl_jwt_raw, nil, false ).first
  @dl_payload.should be_a( Hash )
  @dl_payload[LTI_DL_CONTENT_ITEMS].should be_a( Array )
  @dl_payload[LTI_DL_CONTENT_ITEMS].should_not be_empty
end

Then( 'the deep-link content item is for the bingo game' ) do
  item = @dl_payload[LTI_DL_CONTENT_ITEMS].first
  item.should be_present
  item['type'].should eq 'ltiResourceLink'
  item['url'].should end_with( '/lti/launch' )
  item['title'].should include( @bingo.get_topic( false ) )
  item['custom']['colab_activity_type'].should eq 'bingo_game'
  item['custom']['colab_activity_id'].should eq @bingo.id.to_s
end

Then( 'the deep-link content item is for the project' ) do
  item = @dl_payload[LTI_DL_CONTENT_ITEMS].first
  item.should be_present
  item['type'].should eq 'ltiResourceLink'
  item['url'].should end_with( '/lti/launch' )
  item['title'].should include( @project.get_name( false ) )
  item['custom']['colab_activity_type'].should eq 'project'
  item['custom']['colab_activity_id'].should eq @project.id.to_s
end

Then( 'the deep-link content item is for the experience' ) do
  item = @dl_payload[LTI_DL_CONTENT_ITEMS].first
  item.should be_present
  item['type'].should eq 'ltiResourceLink'
  item['url'].should end_with( '/lti/launch' )
  item['title'].should include( @experience.get_name( false ) )
  item['custom']['colab_activity_type'].should eq 'experience'
  item['custom']['colab_activity_id'].should eq @experience.id.to_s
end

Then( 'the deep-link content item includes a line item for gradebook tracking' ) do
  item = @dl_payload[LTI_DL_CONTENT_ITEMS].first
  item.should be_present
  line_item = item['lineItem']
  line_item.should be_present
  line_item['scoreMaximum'].should be_present
  line_item['label'].should be_present
end

Then( 'the deep-link content item does not include a line item' ) do
  item = @dl_payload[LTI_DL_CONTENT_ITEMS].first
  item.should be_present
  item['lineItem'].should be_nil
end

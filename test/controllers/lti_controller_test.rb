# frozen_string_literal: true

require 'test_helper'

class LtiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deployment = lti_deployments(:moodle_dev)
  end

  # ── Dynamic Registration ─────────────────────────────────────────────────────

  test 'GET /lti/tool_connect returns a valid LTI 1.3 tool configuration' do
    get '/lti/tool_connect'
    assert_response :success
    body = JSON.parse(response.body)

    assert_equal 'web', body['application_type']
    assert_includes body['grant_types'], 'implicit'
    assert_includes body['grant_types'], 'client_credentials'
    assert_includes body['response_types'], 'id_token'
    assert body['initiate_login_uri'].present?
    assert body['jwks_uri'].present?
    assert body['redirect_uris'].present?
    assert body['token_endpoint_auth_method'] == 'private_key_jwt'
    assert body['scope'].include?('lti-nrps')
    assert body['scope'].include?('lti-ags')
    lti_config = body['https://purl.imsglobal.org/spec/lti-tool-configuration']
    assert lti_config.present?
    assert lti_config['target_link_uri'].present?
    assert lti_config['messages'].any? { |m| m['type'] == 'LtiResourceLinkRequest' }

    # The domain claim must match the host (with port when non-standard) of
    # the target_link_uri so that Moodle's domain_targetlinkuri_mismatch check
    # passes.  Moodle's PHP extractor appends the port for non-standard ports:
    #   parse_url($uri)['host'] . ':' . parse_url($uri)['port']
    # Rails' host_with_port omits the port for standard ports (80/443) and
    # includes it otherwise, so the two sides always agree.
    target_host = URI.parse(lti_config['target_link_uri']).then do |u|
      u.port == u.default_port ? u.host : "#{u.host}:#{u.port}"
    end
    assert_equal target_host, lti_config['domain'],
                 'domain claim must equal host:port of target_link_uri to satisfy Moodle'
  end

  test 'POST /lti/tool_connect also returns a valid tool configuration' do
    post '/lti/tool_connect'
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 'web', body['application_type']
  end

  # ── JWKS endpoint ────────────────────────────────────────────────────────────

  test 'GET /.well-known/jwks.json returns key set' do
    get '/.well-known/jwks.json'
    assert_response :success
    body = JSON.parse(response.body)
    assert body.key?('keys')
  end

  # ── OIDC Login Initiation ────────────────────────────────────────────────────

  test 'POST /lti/login with unknown issuer returns 401' do
    post '/lti/login', params: {
      iss: 'https://unknown.platform.example.com',
      login_hint: 'user_42',
      target_link_uri: 'https://localhost/lti/launch'
    }
    assert_response :unauthorized
  end

  test 'GET /lti/login with known issuer redirects to platform auth endpoint' do
    get '/lti/login', params: {
      iss: @deployment.issuer,
      client_id: @deployment.client_id,
      login_hint: 'user_42',
      target_link_uri: 'http://localhost/lti/launch'
    }
    assert_response :redirect
    assert_match(/state=/, response.location)
    assert_match(/nonce=/, response.location)
    assert_match(/response_type=id_token/, response.location)
  end

  # ── LTI Launch ───────────────────────────────────────────────────────────────

  test 'POST /lti/launch without id_token returns 400' do
    post '/lti/launch', params: { state: 'some_state' }
    assert_response :bad_request
  end

  test 'POST /lti/launch with state mismatch returns 401' do
    # state is looked up in the lti_nonces table; 'wrong_state' won't be found
    post '/lti/launch', params: {
      id_token: 'fake.jwt.token',
      state: 'wrong_state'
    }
    assert_response :unauthorized
  end

  # ── Names and Roles ──────────────────────────────────────────────────────────

  test 'POST /lti/names_roles with invalid id returns 404' do
    post '/lti/names_roles/999999'
    assert_response :not_found
  end

  test 'POST /lti/names_roles for resource link without course returns 404' do
    link = lti_resource_links(:assignment_link)
    # assignment_link has no course association
    assert_nil link.course
    post "/lti/names_roles/#{link.id}"
    assert_response :not_found
  end

  test 'POST /lti/names_roles for resource link with course but without names_roles_url returns 422' do
    # Build a resource link pointing to a course (any course from fixtures), without names_roles_url
    course_fixture = courses(:one)
    link = @deployment.lti_resource_links.create!(
      resource_link_id: "rl_nrps_no_url_#{SecureRandom.hex(4)}",
      names_roles_url: nil
    )
    # Use update_columns to bypass AR validation and set course_id directly
    link.update_columns(course_id: course_fixture.id)
    post "/lti/names_roles/#{link.id}"
    assert_response :unprocessable_entity
  end

  # ── Grades ───────────────────────────────────────────────────────────────────

  test 'POST /lti/grades with invalid id returns 404' do
    post '/lti/grades/999999'
    assert_response :not_found
  end

  test 'POST /lti/grades for resource link without assignment returns 404' do
    link = lti_resource_links(:course_link)
    # course_link has no assignment association
    assert_nil link.assignment
    post "/lti/grades/#{link.id}"
    assert_response :not_found
  end

  test 'POST /lti/grades for resource link with assignment but without line_item_url returns 422' do
    # Build a resource link pointing to a course/assignment without line_item_url
    assignment_fixture = lti_resource_links(:assignment_link)
    link = @deployment.lti_resource_links.create!(
      resource_link_id: "rl_ags_no_url_#{SecureRandom.hex(4)}",
      line_item_url: nil
    )
    # We need an assignment_id - use any valid assignment from test_db (if present) else skip
    assignments_table = ActiveRecord::Base.connection.execute('SELECT id FROM assignments LIMIT 1')
    if (row = assignments_table.first)
      link.update_columns(assignment_id: row.first)
      post "/lti/grades/#{link.id}"
      assert_response :unprocessable_entity
    else
      skip 'No assignments in test database'
    end
  end

  # ── Deep Linking ─────────────────────────────────────────────────────────────

  test 'GET /lti/select_content without a deep-linking session returns 400' do
    get '/lti/select_content'
    assert_response :bad_request
  end

  test 'POST /lti/deep_link_response without a deep-linking session returns 400' do
    post '/lti/deep_link_response', params: { activity_type: 'bingo_game', activity_id: '1' }
    assert_response :bad_request
  end

  test 'GET /lti/tool_connect advertises Deep Linking message type' do
    get '/lti/tool_connect'
    assert_response :success
    body = JSON.parse(response.body)
    lti_config = body['https://purl.imsglobal.org/spec/lti-tool-configuration']
    assert lti_config['messages'].any? { |m| m['type'] == 'LtiDeepLinkingRequest' }
  end

  # ── simulate_launch (test-only route) ────────────────────────────────────────

  test 'POST /lti/simulate_launch with unknown issuer returns 401' do
    post '/lti/simulate_launch', params: {
      iss: 'https://unknown.platform.example.com',
      message_type: 'LtiResourceLinkRequest'
    }
    assert_response :unauthorized
  end

  test 'POST /lti/simulate_launch with known issuer creates resource link and redirects' do
    post '/lti/simulate_launch', params: {
      iss: @deployment.issuer,
      message_type: 'LtiResourceLinkRequest',
      resource_link_id: 'test_sim_rl_001',
      context_id: 'ctx_sim_001',
      context_title: 'Simulated Moodle Course',
      user_email: 'sim-user@test.local'
    }
    assert_response :redirect
    assert LtiResourceLink.exists?(resource_link_id: 'test_sim_rl_001')
  end

  test 'POST /lti/simulate_launch with LtiDeepLinkingRequest redirects to select_content' do
    post '/lti/simulate_launch', params: {
      iss: @deployment.issuer,
      message_type: 'LtiDeepLinkingRequest',
      deep_link_return_url: 'http://moodle:8080/mod/lti/return.php',
      user_email: 'sim-dl-user@test.local'
    }
    assert_redirected_to '/lti/select_content'
  end
end

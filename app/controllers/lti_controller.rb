# frozen_string_literal: true

require 'net/http'

# LTI 1.3 controller
# Implements Dynamic Registration, OIDC Login Initiation, Launch,
# Names and Role Provisioning Services (NRPS),
# Assignment and Grade Services (AGS), and Deep Linking.
class LtiController < ApplicationController
  skip_before_action :authenticate_user!
  # skip_around_action :switch_locale, only: [ :deep_link_response ]
  layout :lti_layout

  # LTI pages that are rendered inside the platform's iframe must not be
  # blocked by the default X-Frame-Options: SAMEORIGIN header.  We remove the
  # header entirely for the LTI actions that Moodle embeds in an iframe so that
  # the browser does not refuse the connection.
  after_action :allow_iframe, only: %i[register select_content launch deep_link_response]

  LTI_VERSION = 'http://imsglobal.org/spec/lti/claim/version'
  LTI_MESSAGE_TYPE = 'https://purl.imsglobal.org/spec/lti/claim/message_type'
  LTI_RESOURCE_LINK = 'https://purl.imsglobal.org/spec/lti/claim/resource_link'
  LTI_ROLES = 'https://purl.imsglobal.org/spec/lti/claim/roles'
  LTI_CONTEXT = 'https://purl.imsglobal.org/spec/lti/claim/context'
  LTI_CUSTOM = 'https://purl.imsglobal.org/spec/lti/claim/custom'
  LTI_DEPLOYMENT_ID = 'https://purl.imsglobal.org/spec/lti/claim/deployment_id'
  LTI_NAMES_ROLES_SERVICE = 'https://purl.imsglobal.org/spec/lti-nrps/claim/namesroleservice'
  LTI_AGS_CLAIM = 'https://purl.imsglobal.org/spec/lti-ags/claim/endpoint'

  # LTI Deep Linking 2.0 claims
  LTI_DEEP_LINKING_SETTINGS = 'https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings'
  LTI_DEEP_LINKING_CONTENT_ITEMS = 'https://purl.imsglobal.org/spec/lti-dl/claim/content_items'

  NRPS_SCOPE = 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly'
  AGS_LINEITEM_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/lineitem'
  AGS_RESULT_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly'
  AGS_SCORE_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/score'

  # Maximum length for platform error messages included in log warnings
  # and the registration error view.
  REGISTRATION_ERROR_TRUNCATE_LENGTH = 200

  # GET|POST /lti/tool_connect
  # GET|POST /lti/lti_connect  (alias — Moodle's Dynamic Registration redirect uses this path)
  # LTI Dynamic Registration endpoint.
  # Called by the platform to register CoLab as an LTI 1.3 tool.
  def register
    # The platform may pass an openid_configuration URL and a registration_token
    openid_config_url = params[:openid_configuration]
    registration_token = params[:registration_token]

    platform_config = {}
    if openid_config_url.present?
      begin
        uri = URI(openid_config_url)
        resp = Net::HTTP.get_response(uri)
        platform_config = JSON.parse(resp.body) if resp.is_a?(Net::HTTPSuccess)
      rescue StandardError => e
        logger.warn "LTI Dynamic Registration: could not fetch openid_configuration: #{e.message}"
      end
    end

    tool_config = build_tool_config
    @registration_error = nil
    @client_id = nil
    @platform_issuer = platform_config['issuer']

    # If the platform provided a registration endpoint, POST our config there
    if platform_config['registration_endpoint'].present?
      begin
        reg_uri = URI(platform_config['registration_endpoint'])
        http = Net::HTTP.new(reg_uri.host, reg_uri.port)
        http.use_ssl = reg_uri.scheme == 'https'
        req = Net::HTTP::Post.new(reg_uri.path, 'Content-Type' => 'application/json')
        req['Authorization'] = "Bearer #{registration_token}" if registration_token.present?
        req.body = tool_config.to_json
        reg_response = http.request(req)

        if reg_response.is_a?(Net::HTTPSuccess)
          registered = JSON.parse(reg_response.body)
          # Persist the deployment if we get a client_id back
          if registered['client_id'].present?
            @client_id = registered['client_id']
            LtiDeployment.find_or_create_by(
              issuer: platform_config['issuer'] || registered['client_id'],
              client_id: registered['client_id']
            ) do |d|
              d.auth_login_url = platform_config['authorization_endpoint'] || ''
              d.auth_token_url = platform_config['token_endpoint'] || ''
              d.key_set_url = platform_config['jwks_uri'] || ''
              d.tool_url = tool_base_url
            end
          end
        else
          @registration_error = registration_error_message(
            "Platform returned #{reg_response.code}", reg_response.body
          )
          logger.warn "LTI registration POST failed: #{reg_response.code} #{reg_response.body}"
        end
      rescue StandardError => e
        @registration_error = registration_error_message('Registration error', e.message)
        logger.warn "LTI Dynamic Registration POST error: #{e.message}"
      end
    end

    respond_to do |format|
      format.html { render :register }
      # LTI platforms may not send an explicit JSON Accept header (they may use
      # Accept: */* or omit the header entirely).  format.any ensures we respond
      # with the tool configuration for every non-HTML request rather than
      # raising ActionController::UnknownFormat.
      format.any { render json: tool_config }
    end
  end

  # GET /.well-known/jwks.json
  # This is handled by Keypairs::PublicKeysController#index,
  # but we document the route here for clarity since it's part 
  # of the LTI spec.

  # GET|POST /lti/login
  # LTI 1.3 OIDC Login Initiation.
  # The platform redirects here first; we respond with a redirect back to
  # the platform's auth endpoint with the required OIDC parameters.
  def login
    iss = params[:iss]
    login_hint = params[:login_hint]
    target_link_uri = params[:target_link_uri]
    lti_message_hint = params[:lti_message_hint]
    client_id = params[:client_id]

    deployment = find_deployment(iss, client_id)
    unless deployment
      render json: { error: 'Unknown issuer or client_id' }, status: :unauthorized
      return
    end

    state = SecureRandom.urlsafe_base64(32)
    nonce = SecureRandom.urlsafe_base64(32)

    # Persist state/nonce in session for validation at launch
    session[:lti_state] = state
    session[:lti_nonce] = nonce

    auth_params = {
      response_type: 'id_token',
      response_mode: 'form_post',
      scope: 'openid',
      prompt: 'none',
      client_id: deployment.client_id,
      redirect_uri: lti_launch_url,
      login_hint:,
      state:,
      nonce:
    }
    auth_params[:lti_message_hint] = lti_message_hint if lti_message_hint.present?

    redirect_to "#{deployment.auth_login_url}?#{auth_params.to_query}", allow_other_host: true
  end

  # POST /lti/launch
  # Receives the signed id_token from the platform after OIDC login.
  # Validates the JWT, then routes to either the resource-link handler or the
  # Deep Linking content-selection page based on the LTI message type.
  def launch
    id_token = params[:id_token]
    state = params[:state]

    unless id_token.present? && state.present?
      render json: { error: 'Missing id_token or state' }, status: :bad_request
      return
    end

    unless state == session[:lti_state]
      render json: { error: 'State mismatch' }, status: :unauthorized
      return
    end

    # Decode without verification first to get the issuer and client_id
    unverified_payload, _header = JWT.decode(id_token, nil, false)
    iss = unverified_payload['iss']
    aud = Array(unverified_payload['aud']).first

    deployment = find_deployment(iss, aud)
    unless deployment
      render json: { error: 'Unknown platform' }, status: :unauthorized
      return
    end

    payload = verify_jwt(id_token, deployment)
    if payload.nil?
      render json: { error: 'Invalid JWT' }, status: :unauthorized
      return
    end

    # Nonce check
    if payload['nonce'] != session[:lti_nonce]
      render json: { error: 'Nonce mismatch' }, status: :unauthorized
      return
    end

    # Clear single-use state/nonce
    session.delete(:lti_state)
    session.delete(:lti_nonce)

    message_type = payload[LTI_MESSAGE_TYPE]

    if message_type == 'LtiDeepLinkingRequest'
      handle_deep_linking_request(payload, deployment)
    else
      handle_resource_link_request(payload, deployment)
    end
  end

  # GET /lti/select_content
  # Shown after a successful LtiDeepLinkingRequest launch.
  # Presents available CoLab activities so the instructor can choose which
  # one to deep-link into Moodle (creating a direct activity link and,
  # optionally, a gradebook column).
  def select_content
    unless session[:lti_deep_link_settings].present?
      render plain: 'No active deep-linking session', status: :bad_request
      return
    end

    unless current_user
      redirect_to new_user_session_path
      return
    end

    @deep_link_return_url = session[:lti_deep_link_settings]['deep_link_return_url']
    @accept_types = session[:lti_deep_link_settings]['accept_types'] || ['ltiResourceLink']

    # Show courses where the signed-in user is an instructor (or all courses for admins)
    @courses = if current_user.admin?
                 Course.all.includes(:bingo_games, :projects, :experiences)
               else
                 Course.joins(:rosters)
                       .where(rosters: { user: current_user,
                                         role: [Roster.roles[:instructor], Roster.roles[:assistant]] })
                       .includes(:bingo_games, :projects, :experiences)
               end
  end

  # POST /lti/deep_link_response
  # Builds the signed LTI Deep Linking Response JWT and renders an
  # auto-submitting form that POSTs it back to the platform's
  # deep_link_return_url (completing the Deep Linking flow).
  def deep_link_response
    unless session[:lti_deep_link_settings].present?
      render plain: 'No active deep-linking session', status: :bad_request
      return
    end

    @return_url = session[:lti_deep_link_settings]['deep_link_return_url']
    deployment   = LtiDeployment.find_by(id: session[:lti_deep_link_deployment_id])

    unless deployment && @return_url.present?
      render plain: 'Invalid deep-linking session', status: :bad_request
      return
    end

    content_items = build_content_items(
      params[:activity_type],
      params[:activity_id]
    )

    @jwt = build_deep_link_response_jwt(deployment, content_items)

    # Clear the deep-linking session data – it is single-use
    session.delete(:lti_deep_link_settings)
    session.delete(:lti_deep_link_deployment_id)
    session.delete(:lti_deep_link_context)

    render :deep_link_response
  end

  # POST /lti/names_roles/:id
  # Uses the LTI Names and Role Provisioning Services (NRPS) to sync the
  # roster from the platform into the linked CoLab course.
  def names_roles
    resource_link = LtiResourceLink.find_by(id: params[:id])

    unless resource_link&.course
      render json: { error: 'Resource link not found or not associated with a course' },
             status: :not_found
      return
    end

    deployment = resource_link.lti_deployment

    # We need the NRPS membership endpoint stored on the resource link
    membership_url = resource_link.names_roles_url
    unless membership_url.present?
      render json: { error: 'No Names and Roles endpoint configured for this resource link' },
             status: :unprocessable_entity
      return
    end

    token_response = deployment.request_access_token(scopes: [NRPS_SCOPE])
    access_token = token_response['access_token']

    members = fetch_memberships(membership_url, access_token)
    synced = sync_roster(resource_link.course, members)

    render json: { synced_count: synced, members_received: members.size }
  rescue StandardError => e
    logger.error "NRPS sync error: #{e.message}"
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /lti/grades/:id
  # Pushes grades from CoLab assignment submissions to the LMS via AGS.
  def grades
    resource_link = LtiResourceLink.find_by(id: params[:id])

    unless resource_link&.assignment
      render json: { error: 'Resource link not found or not associated with an assignment' },
             status: :not_found
      return
    end

    deployment = resource_link.lti_deployment
    line_item_url = resource_link.line_item_url

    unless line_item_url.present?
      render json: { error: 'No AGS line item configured for this resource link' },
             status: :unprocessable_entity
      return
    end

    token_response = deployment.request_access_token(
      scopes: [AGS_LINEITEM_SCOPE, AGS_SCORE_SCOPE]
    )
    access_token = token_response['access_token']

    pushed = push_grades(resource_link.assignment, line_item_url, access_token)

    render json: { pushed_count: pushed }
  rescue StandardError => e
    logger.error "AGS grade push error: #{e.message}"
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /lti/simulate_launch  (TEST ENVIRONMENT ONLY)
  # Simulates what Moodle does during an LTI launch without requiring a real
  # signed JWT.  This lets Cucumber @javascript scenarios drive the deep-linking
  # and resource-link flows through the browser without needing a live Moodle.
  #
  # Accepted params:
  #   iss              – issuer that matches an existing LtiDeployment
  #   message_type     – 'LtiResourceLinkRequest' (default) or 'LtiDeepLinkingRequest'
  #   resource_link_id – resource link ID (resource link requests)
  #   course_id        – CoLab course to associate with the resource link (optional)
  #   context_id       – Moodle context identifier
  #   context_title    – Moodle course name
  #   user_email       – email of the CoLab user that "launches"
  #   deep_link_return_url – where Moodle expects the deep-link response form to POST
  def simulate_launch
    raise ActionController::RoutingError, 'Not Found' unless Rails.env.test?

    deployment = LtiDeployment.find_by(issuer: params[:iss])
    unless deployment
      render json: { error: 'Unknown platform' }, status: :unauthorized
      return
    end

    message_type        = params.fetch(:message_type, 'LtiResourceLinkRequest')
    context_id          = params.fetch(:context_id, 'sim_ctx_001')
    context_title       = params.fetch(:context_title, 'Simulated Moodle Course')
    user_email          = params.fetch(:user_email, 'lti-sim@moodle.local')
    deep_link_return_url = params[:deep_link_return_url]

    user = find_or_provision_user(
      'email'       => user_email,
      'given_name'  => 'LTI',
      'family_name' => 'Tester'
    )

    unless user
      render json: { error: 'Could not provision user' }, status: :unprocessable_entity
      return
    end

    if message_type == 'LtiDeepLinkingRequest'
      session[:lti_deep_link_settings] = {
        'deep_link_return_url'                 => deep_link_return_url,
        'accept_types'                         => ['ltiResourceLink'],
        'accept_presentation_document_targets' => %w[iframe window]
      }
      session[:lti_deep_link_deployment_id] = deployment.id
      session[:lti_deep_link_context] = { 'id' => context_id, 'title' => context_title }

      sign_in user
      redirect_to lti_select_content_path
    else
      resource_link_id = params.fetch(:resource_link_id, "sim_rl_#{SecureRandom.hex(4)}")
      resource_link = deployment.lti_resource_links.find_or_initialize_by(
        resource_link_id: resource_link_id
      )
      resource_link.context_id    = context_id
      resource_link.context_title = context_title
      resource_link.course_id     = params[:course_id] if params[:course_id].present?
      resource_link.save

      roles = ['http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor']
      enroll_lti_user(user, { LTI_ROLES => roles }, resource_link.course) if resource_link.course

      sign_in user
      redirect_to '/'
    end
  end

  private

  # Use no Rails layout for LTI views (select_content, deep_link_response,
  # register) that ship their own complete HTML document.  All other LTI
  # actions render JSON / plain text where layout is irrelevant anyway.
  def lti_layout
    action_name.in?(%w[select_content deep_link_response register]) ? false : 'application'
  end

  # Remove the X-Frame-Options header for LTI actions that Moodle embeds in an
  # iframe (register confirmation, content selection, deep-link response).
  # Rails' default SAMEORIGIN would cause Chrome to refuse the connection.
  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end

  # Format a registration error message consistently, truncating the detail
  # portion to REGISTRATION_ERROR_TRUNCATE_LENGTH characters.
  def registration_error_message(prefix, detail)
    "#{prefix}: #{detail.truncate(REGISTRATION_ERROR_TRUNCATE_LENGTH)}"
  end

  def tool_base_url
    "#{request.protocol}#{request.host_with_port}"
  end

  def build_tool_config
    base = tool_base_url
    {
      application_type: 'web',
      grant_types: %w[implicit client_credentials],
      response_types: ['id_token'],
      initiate_login_uri: "#{base}/lti/login",
      redirect_uris: ["#{base}/lti/launch"],
      client_name: 'CoLab',
      jwks_uri: "#{base}/.well-known/jwks.json",
      logo_uri: "#{base}/images/logo.png",
      token_endpoint_auth_method: 'private_key_jwt',
      scope: [NRPS_SCOPE, AGS_LINEITEM_SCOPE, AGS_RESULT_SCOPE, AGS_SCORE_SCOPE].join(' '),
      'https://purl.imsglobal.org/spec/lti-tool-configuration' => {
        # Use host_with_port so that non-standard ports (e.g. 3443 in dev) are
        # included in the domain claim.  Moodle's domain_targetlinkuri_mismatch
        # check extracts host:port from target_link_uri and compares it against
        # this field; omitting the port causes a mismatch on non-standard ports.
        # Rails omits the port for standard ports (80/443), so production is
        # unaffected (e.g. "colab.online" stays unchanged).
        domain: request.host_with_port,
        description: 'CoLab collaborative learning platform',
        target_link_uri: "#{base}/lti/launch",
        'https://purl.imsglobal.org/spec/lti/claim/custom' => {},
        messages: [
          {
            type: 'LtiResourceLinkRequest',
            target_link_uri: "#{base}/lti/launch",
            label: 'CoLab'
          },
          {
            type: 'LtiDeepLinkingRequest',
            target_link_uri: "#{base}/lti/launch",
            label: 'CoLab – Select Activity'
          }
        ],
        claims: %w[iss sub name given_name family_name email]
      }
    }
  end

  def find_deployment(issuer, client_id)
    return nil if issuer.blank?

    scope = LtiDeployment.where(issuer:)
    scope = scope.where(client_id:) if client_id.present?
    scope.first
  end

  def verify_jwt(id_token, deployment)
    jwks_response = deployment.fetch_key_set
    jwks = JWT::JWK::Set.new(jwks_response)
    keys = jwks.filter_map do |jwk|
      jwk.keypair
    rescue StandardError
      nil
    end

    keys.each do |key|
      begin
        payload, _header = JWT.decode(
          id_token, key, true,
          algorithms: %w[RS256 RS384 RS512],
          verify_expiration: true,
          verify_iat: true,
          verify_iss: true,
          iss: deployment.issuer,
          verify_aud: true,
          aud: deployment.client_id
        )
        return payload
      rescue JWT::DecodeError
        next
      end
    end
    nil
  end

  # Upsert the user's roster entry for the given course based on their LTI role
  # claims. The LTI spec expresses roles as full URN strings such as
  # "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor", so we look
  # for 'Instructor' anywhere in the role string rather than doing an exact
  # match. Anyone not identified as an Instructor is treated as an enrolled
  # student. Using find_or_initialize_by ensures this is idempotent: a second
  # launch from the same user simply refreshes their role rather than creating
  # a duplicate Roster record.
  def enroll_lti_user(user, payload, course)
    roles = payload[LTI_ROLES] || []
    is_instructor = roles.any? { |r| r.include?('Instructor') }

    role = if is_instructor
             Roster.roles[:instructor]
           else
             Roster.roles[:enrolled_student]
           end

    roster = Roster.find_or_initialize_by(user:, course:)
    roster.role = role
    roster.save
  end

  def fetch_memberships(membership_url, access_token)
    uri = URI(membership_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{access_token}"
    req['Accept'] = 'application/vnd.ims.lti-nrps.v2.membershipcontainer+json'

    response = http.request(req)
    raise "NRPS request failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    body['members'] || []
  end

  def sync_roster(course, members)
    synced = 0
    members.each do |member|
      email = member['email']
      next unless email.present?

      user = User.joins(:emails).find_by(emails: { email: })
      if user.nil?
        user = User.new(
          email:,
          first_name: member['given_name'] || 'LTI',
          last_name: member['family_name'] || 'User',
          password: SecureRandom.hex(24),
          timezone: 'UTC'
        )
        user.confirm
        user.save
      end

      next unless user.persisted?

      roles = member['roles'] || []
      is_instructor = roles.any? { |r| r.include?('Instructor') }
      role = is_instructor ? Roster.roles[:instructor] : Roster.roles[:enrolled_student]

      roster = Roster.find_or_initialize_by(user:, course:)
      roster.role = role
      roster.save
      synced += 1
    end
    synced
  end

  def push_grades(assignment, line_item_url, access_token)
    score_url = "#{line_item_url.chomp('/')}/scores"
    uri = URI(score_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    pushed = 0
    assignment.submissions.where.not(recorded_score: nil).each do |submission|
      user = submission.user
      next unless user

      score_payload = {
        scoreGiven: submission.recorded_score,
        scoreMaximum: 100,
        comment: '',
        activityProgress: 'Completed',
        gradingProgress: 'FullyGraded',
        userId: user.id.to_s,
        timestamp: submission.updated_at.iso8601
      }.to_json

      req = Net::HTTP::Post.new(uri)
      req['Authorization'] = "Bearer #{access_token}"
      req['Content-Type'] = 'application/vnd.ims.lis.v1.score+json'
      req.body = score_payload

      response = http.request(req)
      if response.is_a?(Net::HTTPSuccess)
        pushed += 1
      else
        logger.warn "AGS score push failed for submission #{submission.id}: HTTP #{response.code}"
      end
    end
    pushed
  end

  # ── Deep-Linking helpers ────────────────────────────────────────────────────

  # Route an LtiDeepLinkingRequest: store settings, sign the user in, and
  # redirect to the content-selection page.
  def handle_deep_linking_request(payload, deployment)
    deep_link_settings = payload[LTI_DEEP_LINKING_SETTINGS] || {}
    session[:lti_deep_link_settings]     = deep_link_settings
    session[:lti_deep_link_deployment_id] = deployment.id
    session[:lti_deep_link_context]      = payload[LTI_CONTEXT]

    user = find_or_provision_user(payload)
    unless user
      render json: { error: 'Could not identify or provision user' }, status: :unprocessable_entity
      return
    end

    sign_in user
    redirect_to lti_select_content_path
  end

  # Route an LtiResourceLinkRequest: find/create the resource link, enroll the
  # user, and redirect to the linked CoLab resource.
  def handle_resource_link_request(payload, deployment)
    resource_link_claim = payload[LTI_RESOURCE_LINK] || {}
    resource_link_id    = resource_link_claim['id']

    resource_link = deployment.lti_resource_links.find_or_initialize_by(
      resource_link_id:
    )
    context = payload[LTI_CONTEXT] || {}
    resource_link.context_id    = context['id']
    resource_link.context_title = context['title']
    resource_link.save

    ags_claim = payload[LTI_AGS_CLAIM]
    if ags_claim&.dig('lineitem').present?
      resource_link.line_item_url ||= ags_claim['lineitem']
      resource_link.save
    end

    user = find_or_provision_user(payload)
    unless user
      render json: { error: 'Could not identify or provision user' }, status: :unprocessable_entity
      return
    end

    enroll_lti_user(user, payload, resource_link.course) if resource_link.course

    sign_in user
    redirect_destination = if resource_link.assignment
                             "/assignment/#{resource_link.assignment.id}"
                           else
                             '/'
                           end
    redirect_to redirect_destination
  end

  # Find an existing CoLab user by e-mail or auto-provision a new one from the
  # LTI payload (or a plain hash with the same keys for simulate_launch).
  def find_or_provision_user(payload)
    email = payload['email']
    return nil unless email.present?

    user = User.joins(:emails).find_by(emails: { email: })
    if user.nil?
      user = User.new(
        email:,
        first_name: payload['given_name'] || 'LTI',
        last_name:  payload['family_name'] || 'User',
        password:   SecureRandom.hex(24),
        timezone:   'UTC'
      )
      user.confirm
      user.save
    end
    user
  end

  # Build the array of LTI Deep Linking content items for the selected activity.
  # Returns a single-item array on success, or an empty array when the activity
  # is not found.
  def build_content_items(activity_type, activity_id)
    base = tool_base_url

    case activity_type
    when 'bingo_game'
      activity = BingoGame.find_by(id: activity_id)
      return [] unless activity

      item = {
        type:  'ltiResourceLink',
        url:   "#{base}/home#bingo/#{activity.id}",
        title: activity.get_topic(false),
        lineItem: {
          scoreMaximum: 100,
          label:        activity.get_topic(false),
          tag:          'grade'
        }
      }
      [item]

    when 'project'
      activity = Project.find_by(id: activity_id)
      return [] unless activity

      item = {
        type:  'ltiResourceLink',
        url:   "#{base}/home#project/#{activity.id}",
        title: activity.get_name(false),
        lineItem: {
          scoreMaximum: 100,
          label:        activity.get_name(false),
          tag:          'grade'
        }
      }
      [item]

    when 'experience'
      activity = Experience.find_by(id: activity_id)
      return [] unless activity

      # Experiences do not currently produce a numeric grade, so no lineItem
      [
        {
          type:  'ltiResourceLink',
          url:   "#{base}/home#experience/#{activity.id}",
          title: activity.get_name(false)
        }
      ]

    else
      []
    end
  end

  # Build and sign the LTI Deep Linking Response JWT that will be POSTed back
  # to the platform's deep_link_return_url.
  def build_deep_link_response_jwt(deployment, content_items)
    keypair = Keypair.current
    now     = Time.now.to_i

    payload = {
      'iss'                          => deployment.client_id,
      'aud'                          => deployment.issuer,
      'iat'                          => now,
      'exp'                          => now + 600,
      'nonce'                        => SecureRandom.urlsafe_base64(16),
      LTI_MESSAGE_TYPE               => 'LtiDeepLinkingResponse',
      LTI_VERSION                    => '1.3.0',
      LTI_DEEP_LINKING_CONTENT_ITEMS => content_items
    }

    JWT.encode(payload, keypair.private_key, 'RS256',
               { kid: keypair.jwk_kid, typ: 'JWT' })
  end
end

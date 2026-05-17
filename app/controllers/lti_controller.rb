# frozen_string_literal: true

require 'net/http'
require 'openssl'

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
  after_action :allow_iframe, only: %i[register select_content launch deep_link_response
                                       link_resource associate_resource_link]

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

  # Maps LTI custom-parameter activity types to their model class and SPA path
  # prefix.  Used by both activity_redirect and associate_and_redirect so the
  # mapping is defined once and cannot drift.
  ACTIVITY_TYPE_CONFIG = {
    'bingo_game' => { model: BingoGame, path: '/home/bingo/enter_candidates/' },
    'project'    => { model: Project,   path: '/home/project/checkin/' },
    'experience' => { model: Experience, path: '/home/experience/' }
  }.freeze
  GRADEBOOK_SUPPORTED_ACTIVITY_TYPES = %w[bingo_game project].freeze

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

    # Persist state/nonce in the database so they survive the cross-site
    # OIDC round-trip without relying on the browser session cookie (which
    # is not reliably sent on cross-site form POSTs in all environments).
    lti_nonce_record = LtiNonce.generate
    state = lti_nonce_record.state
    nonce = lti_nonce_record.nonce

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

    # Look up the state/nonce record in the database.  This avoids any
    # reliance on the browser session cookie, which may not be sent on
    # cross-site form POSTs (the final step of the LTI OIDC flow).
    lti_nonce_record = LtiNonce.find_by(state: state)
    unless lti_nonce_record && !lti_nonce_record.expired?
      render json: { error: 'State mismatch' }, status: :unauthorized
      return
    end

    stored_nonce = lti_nonce_record.nonce

    # Consume the record immediately (single-use)
    lti_nonce_record.destroy

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
    if payload['nonce'] != stored_nonce
      render json: { error: 'Nonce mismatch' }, status: :unauthorized
      return
    end

    # state/nonce already destroyed above; no session cleanup needed

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
    # When a resource-link launch has queued an instructor linking session,
    # always route the user to link_resource so the LMS "Select content"
    # interaction can complete that pending association first.
    if session[:lti_pending_resource_link_id].present?
      redirect_to lti_link_resource_path
      return
    end

    unless session[:lti_deep_link_settings].present?
      render :no_deep_link_session, status: :bad_request
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
      render :no_deep_link_session, status: :bad_request
      return
    end

    @return_url = session[:lti_deep_link_settings]['deep_link_return_url']
    deployment   = LtiDeployment.find_by(id: session[:lti_deep_link_deployment_id])

    unless deployment && @return_url.present?
      @page_title       = t('lti.invalid_deep_link_session.title')
      @page_heading     = t('lti.invalid_deep_link_session.heading')
      @page_explanation = t('lti.invalid_deep_link_session.explanation')
      @error_detail     = t('lti.invalid_deep_link_session.guidance')
      render :no_deep_link_session, status: :bad_request
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

  # GET /lti/link_resource
  # Shown when an instructor launches an LTI resource link that has no
  # associated CoLab activity yet.  Presents the same course/activity listing
  # as select_content but posts back to associate_resource_link instead of
  # returning a deep-link JWT to the platform.
  def link_resource
    unless session[:lti_pending_resource_link_id].present?
      @page_title       = t('lti.link_resource.title')
      @page_heading     = t('lti.link_resource.heading')
      @page_explanation = t('lti.link_resource.no_pending')
      @error_detail     = t('lti.link_resource.no_pending_action')
      render :no_deep_link_session, status: :bad_request
      return
    end

    activity_includes = %i[bingo_games projects experiences]
    @courses = if current_user&.admin?
                 Course.includes(activity_includes)
               else
                 Course.includes(activity_includes).joins(:rosters).where(
                   rosters: { user: current_user,
                               role: [Roster.roles[:instructor], Roster.roles[:assistant]] }
                 )
               end
  end

  # POST /lti/link_resource
  # Associates the pending resource link with the selected CoLab activity and
  # redirects the instructor to that activity.
  def associate_resource_link
    resource_link = LtiResourceLink.find_by(id: session[:lti_pending_resource_link_id])
    unless resource_link
      @page_title       = t('lti.link_resource.title')
      @page_heading     = t('lti.link_resource.heading')
      @page_explanation = t('lti.link_resource.no_pending')
      @error_detail     = t('lti.link_resource.no_pending_action')
      render :no_deep_link_session, status: :bad_request
      return
    end

    activity_type = params[:activity_type]
    activity_id   = params[:activity_id]
    create_gradebook_item = params[:create_gradebook_item] == '1'

    redirect_destination = associate_and_redirect(
      resource_link, activity_type, activity_id, create_gradebook_item: create_gradebook_item
    )

    session.delete(:lti_pending_resource_link_id)
    # lineitems endpoint is captured from the launch claim and only needed for
    # this one linking submit; clear it after association to keep session data
    # single-use like other LTI flow state.
    session.delete(:lti_pending_lineitems_url)
    redirect_to redirect_destination
  end
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
      session[:lti_embedded] = true

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
      session[:lti_embedded] = true
      redirect_to '/'
    end
  end

  private

  # Use no Rails layout for LTI views (select_content, deep_link_response,
  # register, link_resource) that ship their own complete HTML document.  All
  # other LTI actions render JSON / plain text where layout is irrelevant.
  def lti_layout
    action_name.in?(%w[select_content deep_link_response register link_resource]) ? false : 'application'
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
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if http.use_ssl?
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if http.use_ssl?

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
    session[:lti_embedded]               = true

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

    # Custom parameters may carry a CoLab course ID (course-level deep link)
    # or an activity type + ID (activity-level deep link).  Use these to
    # associate the resource link on first launch.
    custom = payload[LTI_CUSTOM] || {}
    if custom['colab_course_id'].present? && resource_link.course_id.nil?
      resource_link.course_id = custom['colab_course_id'].to_i
    end

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

    # Mark the session as LTI-embedded so that ApplicationController removes
    # X-Frame-Options from all subsequent responses in this session, preventing
    # Chrome from blocking CoLab pages inside the LMS iframe.
    session[:lti_embedded] = true

    # If the resource link has no associated activity or course yet, check
    # custom params for an activity hint from the deep-link content item.
    # If the user is an instructor and there is still no target, show the
    # activity-linking screen so they can connect the link to a CoLab activity.
    if resource_link.assignment.nil? && resource_link.course.nil? && resource_link.activity_type.nil?
      activity_type = custom['colab_activity_type']
      activity_id   = custom['colab_activity_id']

      if activity_type.present? && activity_id.present?
        redirect_destination = associate_and_redirect(
          resource_link, activity_type, activity_id, create_gradebook_item: false
        )
        redirect_to redirect_destination
        return
      end

      roles = payload[LTI_ROLES] || []
      if roles.any? { |r| r.include?('Instructor') }
        session[:lti_pending_resource_link_id] = resource_link.id
        session[:lti_pending_lineitems_url] = ags_claim['lineitems'] if ags_claim&.dig('lineitems').present?
        redirect_to lti_link_resource_path
        return
      end
    end

    redirect_destination = if resource_link.assignment
                             "/assignment/#{resource_link.assignment.id}"
                           elsif resource_link.activity_type.present? && resource_link.activity_id.present?
                             activity_redirect(resource_link.activity_type, resource_link.activity_id.to_s)
                           elsif resource_link.course
                             '/home'
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

  # Return a CoLab redirect path for a given activity type and ID carried
  # via LTI custom parameters (e.g. from an activity-level deep link).
  # Uses ACTIVITY_TYPE_CONFIG as the single source of truth for path prefixes.
  def activity_redirect(activity_type, activity_id)
    config = ACTIVITY_TYPE_CONFIG[activity_type]
    unless config
      logger.warn "LTI activity_redirect: unrecognized activity_type #{activity_type.inspect}"
      return '/home'
    end
    "#{config[:path]}#{activity_id}"
  end

  # Associate a resource link with the given activity (storing the course
  # association for future enrollment), then return the redirect path.
  # Uses ACTIVITY_TYPE_CONFIG as the single source of truth for model classes.
  def associate_and_redirect(resource_link, activity_type, activity_id, create_gradebook_item: false)
    if activity_type == 'course'
      course = Course.find_by(id: activity_id)
      if course
        resource_link.course = course
        resource_link.save
      end
      return '/home'
    end

    config = ACTIVITY_TYPE_CONFIG[activity_type]
    unless config
      logger.warn "LTI associate_and_redirect: unrecognized activity_type #{activity_type.inspect}"
      return '/'
    end

    activity = config[:model].find_by(id: activity_id)
    if activity
      resource_link.course        = activity.course
      resource_link.activity_type = activity_type
      resource_link.activity_id   = activity_id.to_i
      if create_gradebook_item &&
         GRADEBOOK_SUPPORTED_ACTIVITY_TYPES.include?(activity_type) &&
         resource_link.line_item_url.blank?
        line_item_url = create_line_item_for_activity(resource_link, activity_type, activity)
        resource_link.line_item_url = line_item_url if line_item_url.present?
      end
      resource_link.save
      sync_activity_lti_connection(activity, resource_link)
    end
    activity_redirect(activity_type, activity_id)
  end

  # Create an LMS line item for the selected activity using the platform's AGS
  # lineitems endpoint captured from the launch claim. Returns the created line
  # item URL (id) when successful, or nil when creation is unavailable/failed.
  def create_line_item_for_activity(resource_link, activity_type, activity)
    lineitems_url = session[:lti_pending_lineitems_url]
    return nil unless lineitems_url.present?

    deployment = resource_link.lti_deployment
    token_response = deployment.request_access_token(scopes: [AGS_LINEITEM_SCOPE])
    access_token = token_response['access_token']
    unless access_token.present?
      logger.warn "LTI create_line_item_for_activity: token response missing access_token"
      return nil
    end

    uri = parse_uri_or_nil(lineitems_url)
    unless uri
      logger.warn 'LTI create_line_item_for_activity: invalid lineitems URL'
      return nil
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-Type'] = 'application/vnd.ims.lis.v2.lineitem+json'
    request['Accept'] = 'application/vnd.ims.lis.v2.lineitem+json'
    request.body = {
      label: activity_title(activity_type, activity),
      scoreMaximum: 100,
      tag: 'grade',
      resourceId: "#{activity_type}:#{activity.id}"
    }.to_json

    response = http.request(request)
    return nil unless response.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(response.body.presence || '{}')
    return parsed['id'] if parsed['id'].present?

    location_header = response['Location']
    location_uri = parse_uri_or_nil(location_header) if location_header.present?
    if location_uri && %w[http https].include?(location_uri.scheme)
      logger.info 'LTI create_line_item_for_activity: using Location header fallback for line item URL'
      return location_uri.to_s
    end

    logger.warn 'LTI create_line_item_for_activity: no usable line item URL in response body or Location header'
    nil
  rescue JSON::ParserError => e
    logger.warn "LTI create_line_item_for_activity: invalid JSON response (#{e.message}), body: #{response&.body.inspect}"
    nil
  rescue StandardError => e
    logger.warn "LTI create_line_item_for_activity failed: #{e.message}"
    nil
  end

  def parse_uri_or_nil(url)
    return nil if url.blank?

    URI.parse(url)
  rescue URI::InvalidURIError
    nil
  end

  # Return the human-readable activity title used when creating AGS line items.
  def activity_title(activity_type, activity)
    case activity_type
    when 'bingo_game' then activity.get_topic(false)
    else activity.get_name(false)
    end
  end

  # Sync deployment and AGS settings from an LTI resource link to the selected
  # activity's LtiConnection so the activity's LTI Grade Passback panel is
  # automatically populated after linking.
  def sync_activity_lti_connection(activity, resource_link)
    deployment = resource_link.lti_deployment
    connection = activity.lti_connection || activity.build_lti_connection

    attributes = {
      ags_access_token_url: deployment.auth_token_url,
      client_id: deployment.client_id,
      deployment_id: deployment.deployment_id,
      iss: deployment.issuer
    }
    # Preserve any existing activity line_item_url when the current resource
    # link has no line item yet (for example, when an instructor links without
    # creating a gradebook item). This avoids unintentionally clearing a valid
    # previously configured grade passback target.
    attributes[:line_item_url] = resource_link.line_item_url if resource_link.line_item_url.present?

    connection.assign_attributes(attributes)
    return if connection.save

    logger.warn "LTI sync_activity_lti_connection: save failed (#{connection.errors.full_messages.join(', ')})"
  rescue StandardError => e
    logger.warn "LTI sync_activity_lti_connection failed: #{e.message}"
  end

  # Build the array of LTI Deep Linking content items for the selected activity
  # or course. Returns a single-item array on success, or an empty array when
  # the activity/course is not found.
  def build_content_items(activity_type, activity_id)
    base = tool_base_url

    case activity_type
    when 'course'
      course = Course.find_by(id: activity_id)
      return [] unless course

      # Course-level resource link: sends students to the CoLab home page for
      # this course.  The CoLab course ID is encoded in the custom parameters
      # so that the LTI launch handler can associate the resource link with the
      # correct course on first launch.
      [
        {
          type:   'ltiResourceLink',
          url:    "#{base}/lti/launch",
          title:  course.get_name(false),
          custom: { 'colab_course_id' => course.id.to_s }
        }
      ]

    when 'bingo_game'
      activity = BingoGame.find_by(id: activity_id)
      return [] unless activity

      item = {
        type:   'ltiResourceLink',
        url:    "#{base}/lti/launch",
        title:  activity.get_topic(false),
        custom: {
          'colab_activity_type' => 'bingo_game',
          'colab_activity_id'   => activity.id.to_s,
          'colab_course_id'     => activity.course_id.to_s
        },
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
        type:   'ltiResourceLink',
        url:    "#{base}/lti/launch",
        title:  activity.get_name(false),
        custom: {
          'colab_activity_type' => 'project',
          'colab_activity_id'   => activity.id.to_s,
          'colab_course_id'     => activity.course_id.to_s
        },
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
          type:   'ltiResourceLink',
          url:    "#{base}/lti/launch",
          title:  activity.get_name(false),
          custom: {
            'colab_activity_type' => 'experience',
            'colab_activity_id'   => activity.id.to_s,
            'colab_course_id'     => activity.course_id.to_s
          }
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

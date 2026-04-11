# frozen_string_literal: true

require 'net/http'

# LTI 1.3 controller
# Implements Dynamic Registration, OIDC Login Initiation, Launch,
# Names and Role Provisioning Services (NRPS), and
# Assignment and Grade Services (AGS).
class LtiController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  LTI_VERSION = 'http://imsglobal.org/spec/lti/claim/version'
  LTI_MESSAGE_TYPE = 'https://purl.imsglobal.org/spec/lti/claim/message_type'
  LTI_RESOURCE_LINK = 'https://purl.imsglobal.org/spec/lti/claim/resource_link'
  LTI_ROLES = 'https://purl.imsglobal.org/spec/lti/claim/roles'
  LTI_CONTEXT = 'https://purl.imsglobal.org/spec/lti/claim/context'
  LTI_CUSTOM = 'https://purl.imsglobal.org/spec/lti/claim/custom'
  LTI_DEPLOYMENT_ID = 'https://purl.imsglobal.org/spec/lti/claim/deployment_id'
  LTI_NAMES_ROLES_SERVICE = 'https://purl.imsglobal.org/spec/lti-nrps/claim/namesroleservice'
  LTI_AGS_CLAIM = 'https://purl.imsglobal.org/spec/lti-ags/claim/endpoint'

  NRPS_SCOPE = 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly'
  AGS_LINEITEM_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/lineitem'
  AGS_RESULT_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly'
  AGS_SCORE_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/score'

  # GET|POST /lti/tool_connect
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
          logger.warn "LTI registration POST failed: #{reg_response.code} #{reg_response.body}"
        end
      rescue StandardError => e
        logger.warn "LTI Dynamic Registration POST error: #{e.message}"
      end
    end

    render json: tool_config
  end

  # GET /.well-known/jwks.json
  # Expose our public keys so platforms can verify our signed JWTs.
  def jwks
    render json: { keys: Keypair.jwt_encode_keys }
  end

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
  # Validates the JWT, finds/creates the resource link, and redirects the
  # user to the appropriate CoLab resource.
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

    # Find or create resource link
    resource_link_claim = payload[LTI_RESOURCE_LINK] || {}
    resource_link_id = resource_link_claim['id']

    resource_link = deployment.lti_resource_links.find_or_initialize_by(
      resource_link_id:
    )
    context = payload[LTI_CONTEXT] || {}
    resource_link.context_id = context['id']
    resource_link.context_title = context['title']
    resource_link.save

    # Store AGS line item URL if provided
    ags_claim = payload[LTI_AGS_CLAIM]
    if ags_claim&.dig('lineitem').present?
      resource_link.line_item_url ||= ags_claim['lineitem']
      resource_link.save
    end

    # Find user by email
    user = User.joins(:emails).find_by(emails: { email: payload['email'] }) if payload['email'].present?

    # Auto-provision user if not found and email is present
    if user.nil? && payload['email'].present?
      user = User.new(
        email: payload['email'],
        first_name: payload['given_name'] || 'LTI',
        last_name: payload['family_name'] || 'User',
        password: SecureRandom.hex(24),
        timezone: 'UTC'
      )
      user.confirm
      user.save
    end

    unless user
      render json: { error: 'Could not identify or provision user' }, status: :unprocessable_entity
      return
    end

    # Enroll the user in the course if we have one
    if resource_link.course
      enroll_lti_user(user, payload, resource_link.course)
    end

    # Sign in via Devise and redirect
    sign_in user
    redirect_destination = if resource_link.assignment
                             "/assignment/#{resource_link.assignment.id}"
                           elsif resource_link.course
                             '/'
                           else
                             '/'
                           end
    redirect_to redirect_destination
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

  private

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
        domain: request.host,
        description: 'CoLab collaborative learning platform',
        target_link_uri: "#{base}/lti/launch",
        'https://purl.imsglobal.org/spec/lti/claim/custom' => {},
        messages: [
          {
            type: 'LtiResourceLinkRequest',
            target_link_uri: "#{base}/lti/launch",
            label: 'CoLab'
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
end

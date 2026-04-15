# frozen_string_literal: true

class LtiConnection < ApplicationRecord
  belongs_to :connectable, polymorphic: true

  validates :connectable, presence: true

  # Returns true if this connection has sufficient configuration to push grades.
  def configured?
    line_item_url.present? && ags_access_token_url.present? && client_id.present?
  end

  # Push a score for a single user to the LMS via LTI AGS.
  #
  # @param user_id [String] The LTI user identifier (sub claim) for the student
  # @param score_given [Numeric] The raw score
  # @param score_maximum [Numeric] The maximum possible score (default: 100)
  # @param activity_progress [String] LTI progress state (default: 'Completed')
  # @param grading_progress [String] LTI grading state (default: 'FullyGraded')
  # @return [Hash] result with :success and :error keys
  def push_score( user_id:, score_given:, score_maximum: 100, activity_progress: 'Completed',
                  grading_progress: 'FullyGraded' )
    return { success: false, error: 'LTI connection is not configured' } unless configured?

    token_result = fetch_access_token
    return token_result unless token_result[:success]

    access_token = token_result[:access_token]
    scores_url = "#{line_item_url.chomp( '/' )}/scores"

    payload = {
      userId: user_id,
      scoreGiven: score_given,
      scoreMaximum: score_maximum,
      activityProgress: activity_progress,
      gradingProgress: grading_progress,
      timestamp: Time.current.iso8601
    }

    begin
      response = post_to_lms( scores_url, payload.to_json, access_token,
                               'application/vnd.ims.lis.v1.score+json' )
      if response.code.to_i.between?( 200, 299 )
        { success: true }
      else
        { success: false, error: "LMS returned HTTP #{response.code}: #{response.body}" }
      end
    rescue StandardError => e
      Rails.logger.error "LTI grade push failed: #{e.message}"
      { success: false, error: e.message }
    end
  end

  private

  # Fetch an OAuth2 client credentials access token from the LTI platform.
  def fetch_access_token
    require 'net/http'
    require 'uri'

    jwt_assertion = build_client_assertion
    uri = URI.parse( ags_access_token_url )
    http = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new( uri.request_uri )
    request.set_form_data(
      'grant_type'            => 'client_credentials',
      'client_assertion_type' => 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      'client_assertion'      => jwt_assertion,
      'scope'                 => 'https://purl.imsglobal.org/spec/lti-ags/scope/score'
    )

    response = http.request( request )
    if response.code.to_i.between?( 200, 299 )
      token_data = JSON.parse( response.body )
      { success: true, access_token: token_data['access_token'] }
    else
      { success: false, error: "Token request failed with HTTP #{response.code}: #{response.body}" }
    end
  rescue StandardError => e
    Rails.logger.error "LTI token fetch failed: #{e.message}"
    { success: false, error: e.message }
  end

  # Build a signed JWT client assertion for the OAuth2 token request.
  def build_client_assertion
    now = Time.current.to_i
    claims = {
      iss: client_id,
      sub: client_id,
      aud: ags_access_token_url,
      iat: now,
      exp: now + 300,
      jti: SecureRandom.uuid
    }
    Keypairs.sign( payload: claims )
  end

  # POST JSON to the LMS endpoint with a Bearer token.
  def post_to_lms( url, body, access_token, content_type )
    require 'net/http'
    require 'uri'

    uri = URI.parse( url )
    http = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new( uri.request_uri )
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-Type'] = content_type
    request.body = body

    http.request( request )
  end
end

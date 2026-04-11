# frozen_string_literal: true

class LtiDeployment < ApplicationRecord
  has_many :lti_resource_links, dependent: :destroy

  validates :issuer, :client_id, :auth_login_url, :auth_token_url, :key_set_url, presence: true
  validates :client_id, uniqueness: { scope: :issuer }

  # Fetch and cache the platform's JWK Set for JWT verification.
  # Returns the decoded key set hash or raises on HTTP/parse failure.
  def fetch_key_set
    require 'net/http'
    uri = URI(key_set_url)
    response = Net::HTTP.get_response(uri)
    raise "Failed to fetch JWKS from #{key_set_url}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  # Request an OAuth 2.0 access token from the platform using a
  # client_credentials grant signed with our private keypair.
  def request_access_token(scopes:)
    keypair = Keypair.current
    private_key = keypair.private_key

    now = Time.now.to_i
    jwt_payload = {
      iss: client_id,
      sub: client_id,
      aud: auth_token_url,
      iat: now,
      exp: now + 300,
      jti: SecureRandom.uuid
    }

    token = JWT.encode(jwt_payload, private_key, 'RS256', { kid: keypair.jwk_kid, typ: 'JWT' })

    uri = URI(auth_token_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(
      grant_type: 'client_credentials',
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: token,
      scope: scopes.join(' ')
    )

    response = http.request(request)
    raise "Token request failed: HTTP #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end
end

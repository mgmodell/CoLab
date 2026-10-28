# frozen_string_literal: true

require 'net/http'
require 'openssl'

class LtiResourceLink < ApplicationRecord
  belongs_to :lti_deployment
  belongs_to :course, optional: true
  belongs_to :assignment, optional: true

  validates :resource_link_id, presence: true
  validates :resource_link_id, uniqueness: { scope: :lti_deployment_id }

  def self.fetch_membership_container(membership_url, access_token)
    uri = URI(membership_url)
    raise ArgumentError, 'Invalid NRPS membership URL' unless %w[http https].include?(uri.scheme) && uri.host

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if http.use_ssl?

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = 'Bearer '.concat(access_token)
    request['Accept'] = 'application/vnd.ims.lti-nrps.v2.membershipcontainer+json'

    response = http.request(request)
    raise "NRPS request failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end
end

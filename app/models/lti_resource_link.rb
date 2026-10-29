# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'uri'

class LtiResourceLink < ApplicationRecord
  AGS_SCORE_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/score'

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
    request['Authorization'] = ['Bearer', access_token].join(' ')
    request['Accept'] = 'application/vnd.ims.lti-nrps.v2.membershipcontainer+json'

    response = http.request(request)
    raise "NRPS request failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end
  
  def push_score( user_id:, score_given:, score_maximum: 100, timestamp: Time.current )
    return false if line_item_url.blank?

    access_token = lti_deployment.request_access_token( scopes: [AGS_SCORE_SCOPE] ).fetch( 'access_token' )
    uri = URI( "#{line_item_url.chomp( '/')}/scores" )
    http = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new( uri.request_uri )
    request['Authorization'] = ['Bearer', access_token].join( ' ' )
    request['Content-Type'] = 'application/vnd.ims.lis.v1.score+json'
    request.body = {
      userId: user_id,
      scoreGiven: score_given,
      scoreMaximum: score_maximum,
      comment: '',
      activityProgress: 'Completed',
      gradingProgress: 'FullyGraded',
      timestamp: timestamp.iso8601
    }.to_json

    response = http.request( request )
    unless response.is_a?( Net::HTTPSuccess )
      Rails.logger.warn "AGS score push failed for submission #{user_id}: HTTP #{response.code}"
    end
    response.is_a?( Net::HTTPSuccess )
  end
end

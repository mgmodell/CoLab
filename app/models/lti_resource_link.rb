# frozen_string_literal: true

require 'net/http'
require 'uri'

class LtiResourceLink < ApplicationRecord
  AGS_SCORE_SCOPE = 'https://purl.imsglobal.org/spec/lti-ags/scope/score'

  belongs_to :lti_deployment
  belongs_to :course, optional: true
  belongs_to :assignment, optional: true

  validates :resource_link_id, presence: true
  validates :resource_link_id, uniqueness: { scope: :lti_deployment_id }

  def push_score( user_id:, score_given:, score_maximum: 100, timestamp: Time.current )
    return false if line_item_url.blank?

    access_token = lti_deployment.request_access_token( scopes: [AGS_SCORE_SCOPE] ).fetch( 'access_token' )
    uri = URI( "#{line_item_url.chomp( '/')}/scores" )
    http = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new( uri.request_uri )
    request['Authorization'] = "******"
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

# frozen_string_literal: true

class LtiResourceLink < ApplicationRecord
  belongs_to :lti_deployment
  belongs_to :course, optional: true
  belongs_to :assignment, optional: true

  validates :resource_link_id, presence: true
  validates :resource_link_id, uniqueness: { scope: :lti_deployment_id }
end

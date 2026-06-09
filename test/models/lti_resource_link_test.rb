# frozen_string_literal: true

require 'test_helper'

class LtiResourceLinkTest < ActiveSupport::TestCase
  def deployment
    lti_deployments(:moodle_dev)
  end

  def valid_attrs
    {
      lti_deployment: deployment,
      resource_link_id: 'link_xyz_001'
    }
  end

  test 'is valid with required attributes' do
    link = LtiResourceLink.new(valid_attrs)
    assert link.valid?, "Expected valid but got: #{link.errors.full_messages}"
  end

  test 'is invalid without resource_link_id' do
    link = LtiResourceLink.new(valid_attrs.except(:resource_link_id))
    assert_not link.valid?
    assert_includes link.errors[:resource_link_id], "can't be blank"
  end

  test 'is invalid without lti_deployment' do
    link = LtiResourceLink.new(valid_attrs.except(:lti_deployment))
    assert_not link.valid?
  end

  test 'enforces uniqueness of resource_link_id scoped to deployment' do
    LtiResourceLink.create!(valid_attrs)
    duplicate = LtiResourceLink.new(valid_attrs)
    assert_not duplicate.valid?
    assert duplicate.errors[:resource_link_id].any?
  end

  test 'allows same resource_link_id for different deployments' do
    LtiResourceLink.create!(valid_attrs)
    other_deployment = LtiDeployment.create!(
      issuer: 'https://other.example.com',
      client_id: 'other_client',
      auth_login_url: 'https://other.example.com/auth',
      auth_token_url: 'https://other.example.com/token',
      key_set_url: 'https://other.example.com/jwks'
    )
    other_link = LtiResourceLink.new(
      lti_deployment: other_deployment,
      resource_link_id: valid_attrs[:resource_link_id]
    )
    assert other_link.valid?
  end

  test 'course association is optional' do
    link = LtiResourceLink.new(valid_attrs)
    assert link.valid?
    assert_nil link.course
  end

  test 'assignment association is optional' do
    link = LtiResourceLink.new(valid_attrs)
    assert link.valid?
    assert_nil link.assignment
  end

  test 'fixture course_link is valid' do
    link = lti_resource_links(:course_link)
    assert link.valid?
    assert_equal 'res_link_001', link.resource_link_id
    assert link.names_roles_url.present?
  end

  test 'fixture assignment_link is valid' do
    link = lti_resource_links(:assignment_link)
    assert link.valid?
    assert_equal 'res_link_002', link.resource_link_id
    assert link.line_item_url.present?
  end

  test 'activity_type and activity_id are optional' do
    link = LtiResourceLink.new(valid_attrs)
    assert link.valid?
    assert_nil link.activity_type
    assert_nil link.activity_id
  end

  test 'activity_type and activity_id are persisted when set' do
    link = LtiResourceLink.create!(valid_attrs.merge(activity_type: 'bingo_game', activity_id: 42))
    link.reload
    assert_equal 'bingo_game', link.activity_type
    assert_equal 42, link.activity_id
  end
end

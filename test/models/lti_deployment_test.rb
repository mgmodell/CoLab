# frozen_string_literal: true

require 'test_helper'

class LtiDeploymentTest < ActiveSupport::TestCase
  def valid_deployment_attrs
    {
      issuer: 'https://platform.example.com',
      client_id: 'client_abc123',
      auth_login_url: 'https://platform.example.com/oidc/auth',
      auth_token_url: 'https://platform.example.com/oidc/token',
      key_set_url: 'https://platform.example.com/oidc/jwks'
    }
  end

  test 'is valid with all required attributes' do
    deployment = LtiDeployment.new(valid_deployment_attrs)
    assert deployment.valid?, "Expected valid but got: #{deployment.errors.full_messages}"
  end

  test 'is invalid without issuer' do
    deployment = LtiDeployment.new(valid_deployment_attrs.except(:issuer))
    assert_not deployment.valid?
    assert_includes deployment.errors[:issuer], "can't be blank"
  end

  test 'is invalid without client_id' do
    deployment = LtiDeployment.new(valid_deployment_attrs.except(:client_id))
    assert_not deployment.valid?
    assert_includes deployment.errors[:client_id], "can't be blank"
  end

  test 'is invalid without auth_login_url' do
    deployment = LtiDeployment.new(valid_deployment_attrs.except(:auth_login_url))
    assert_not deployment.valid?
    assert_includes deployment.errors[:auth_login_url], "can't be blank"
  end

  test 'is invalid without auth_token_url' do
    deployment = LtiDeployment.new(valid_deployment_attrs.except(:auth_token_url))
    assert_not deployment.valid?
    assert_includes deployment.errors[:auth_token_url], "can't be blank"
  end

  test 'is invalid without key_set_url' do
    deployment = LtiDeployment.new(valid_deployment_attrs.except(:key_set_url))
    assert_not deployment.valid?
    assert_includes deployment.errors[:key_set_url], "can't be blank"
  end

  test 'enforces uniqueness of client_id scoped to issuer' do
    LtiDeployment.create!(valid_deployment_attrs)
    duplicate = LtiDeployment.new(valid_deployment_attrs)
    assert_not duplicate.valid?
    assert duplicate.errors[:client_id].any?
  end

  test 'allows same client_id for different issuers' do
    LtiDeployment.create!(valid_deployment_attrs)
    different_issuer = LtiDeployment.new(
      valid_deployment_attrs.merge(issuer: 'https://other.example.com')
    )
    assert different_issuer.valid?
  end

  test 'has many lti_resource_links' do
    deployment = LtiDeployment.new(valid_deployment_attrs)
    assert_respond_to deployment, :lti_resource_links
  end

  test 'fixture moodle_dev is valid' do
    deployment = lti_deployments(:moodle_dev)
    assert deployment.valid?
    assert_equal 'http://moodle:8080', deployment.issuer
  end
end

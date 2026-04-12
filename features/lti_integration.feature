Feature: LTI 1.3 Tool Integration
  As an LMS administrator (e.g. Moodle)
  I want to register CoLab as an LTI 1.3 tool
  So that students and instructors can launch CoLab activities from within the LMS

  Scenario: LMS performs Dynamic Registration and receives a valid tool configuration
    When the LMS requests the LTI tool configuration
    Then the response contains a valid LTI 1.3 tool configuration
    And the tool configuration has a login URI
    And the tool configuration has a launch URI
    And the tool configuration has a JWKS URI

  Scenario: Tool serves JWKS for platform JWT verification
    When the platform requests the JWKS endpoint
    Then the response contains a JSON key set with at least one key

  Scenario: OIDC Login initiation with known issuer redirects to platform
    Given a registered LTI deployment exists for issuer "http://moodle:8080"
    When the platform initiates login for issuer "http://moodle:8080"
    Then the response redirects to the platform authorization endpoint
    And the redirect contains state and nonce parameters

  Scenario: OIDC Login initiation with unknown issuer is rejected
    When the platform initiates login for issuer "https://unknown.lms.example.com"
    Then the response status is 401

  Scenario: LTI Launch with missing id_token returns error
    When a launch request is sent without an id_token
    Then the response status is 400

  Scenario: NRPS - names_roles endpoint returns not found for missing resource link
    When the NRPS sync is requested for a non-existent resource link
    Then the response status is 404

  Scenario: AGS - grades endpoint returns not found for missing resource link
    When the AGS grade push is requested for a non-existent resource link
    Then the response status is 404

  Scenario: LTI Deployment can be created with all required fields
    Given a new LTI deployment with all required fields
    Then the deployment is valid and persisted

  Scenario: LTI Resource Link associates a deployment with a context
    Given a registered LTI deployment exists for issuer "http://moodle:8080"
    And a resource link for that deployment with resource_link_id "ctx_link_bdd_001"
    Then the resource link is valid
    And the resource link belongs to the deployment

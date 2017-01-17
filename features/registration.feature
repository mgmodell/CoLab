Feature: User registration
  In order to be able to use the collected data,
  Students must be presented an informed consent form
  and be asked to provide demographic data.

  Background:
    Given a user has signed up

  Scenario: Registered user provides consent and demographics.
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project has a consent form
    Given the user is the "last" user
    Given the user "has not" had demographics requested
    When the user logs in
    Then the user will see a consent request
    When the user "does" provide consent
    Then the user will see a request for demographics
    When the user "does" fill in demographics data
    When the user visits the index
    Then the user will see the assessment listing page

  Scenario: Registered user is not assigned to a research project and therefore is not asked for demographics
    Given the user "has not" had demographics requested
    When the user logs in
    Then the user will see the assessment listing page

  Scenario: Registered user does not provide consent
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project has a consent form
    Given the user is the "last" user
    Given the user "has not" had demographics requested
    When the user logs in
    Then the user will see a consent request
    When the user "does not" provide consent
    Then the user will see a request for demographics
    When the user "does" fill in demographics data
    When the user visits the index
    Then the user will see the assessment listing page

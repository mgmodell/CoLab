Feature: Submitting Reports
  Students must be able to reach and complete their weekly installments

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"

  Scenario: User should be able to complete an open weekly installment
    Given the project measures 3 factors
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 600, "evenly" across each column
    When the user submits the installment
    Then there should be 0 project save errors

  Scenario: User should not be able to edit a completed weekly installment
    Given the project measures 4 factors
    Given the project has a group with 4 confirmed users
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Then the user logs in and submits an installment
    When the user returns home
    Then the assessment should show up as completed

  Scenario: An installment's factor values can be randomly assigned
    Given the project measures 3 factors
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 0, "randomly" across each column
    When the user submits the installment
    Then there should be 0 project save errors

  Scenario: A installment's factor column need not sum to 600 or be distributed evenly
    Given the project measures 3 factors
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 0, "randomly" across each column
    When the user submits the installment
    Then there should be 0 project save errors

  Scenario: A installment's factor column need not sum to 600
    Given the project measures 3 factors
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 1200, "evenly" across each column
    When the user submits the installment
    Then there should be 0 project save errors

  Scenario: User should not be able to submit an installment after the assessment has closed
    Given the project measures 3 factors
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    Given today is "tomorrow 23:57"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 600, "evenly" across each column
    Given today is "in 10 minutes"
    When the user submits the installment
    Then the user should see an error indicating that the installment request expired

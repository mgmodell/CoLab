Feature: Presenting Consent Forms
  In order to be allowed to use the collected data,
  Students must be able to consent to its usage.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"

  Scenario: User should be presented with an unpresented project consent form if one exists
    When the user logs in
    Then the user should see a successful login message
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a consent form
    Given the consent form started "1 month ago" and ends "1 month later"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user visits the index
    Then the user will see a consent request

  Scenario: User should be presented with an active unpresented global consent form with no end date if one exists
    When the user logs in
    Then the user should see a successful login message
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given there is a global consent form
    Given the consent form started "1 month ago" and ends "NULL"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user visits the index
    Then the user will see a consent request

  Scenario: User should be presented with an unpresented global consent form if one exists
    When the user logs in
    Then the user should see a successful login message
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given there is a global consent form
    Given the consent form started "1 month ago" and ends "1 month later"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user visits the index
    Then the user will see a consent request

  Scenario: User should be presented with an unpresented global and project consent form if one exists
    When the user logs in
    Then the user should see a successful login message
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a consent form
    Given the consent form started "1 month ago" and ends "1 month later"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given there is a global consent form
    Given the consent form started "yesterday" and ends "tomorrow"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user visits the index
    Then the user will see a consent request

  Scenario: User should be able to access a presented consent form, but not be redirected to it
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a consent form
    Given the consent form started "1 month ago" and ends "1 month later"
    Given the consent form "is" active
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form

  Scenario: If no consent form is attached to an assessment, none should be presented
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should not see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form

  Scenario: If an inactive consent form is attached to an assessment, none should be presented
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has been activated
    Given the user "has" had demographics requested
    Given the project has a consent form
    Given the consent form started "1 month ago" and ends "1 month later"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then user should not see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form

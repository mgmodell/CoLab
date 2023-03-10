Feature: Presenting Consent Forms
  In order to be allowed to use the collected data,
  Students must be able to consent to its usage.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"
    Given reset time clock to now

@javascript
  Scenario: (Project)User should be presented with an unpresented course consent form if one exists
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    When the user logs in
    Then the user should see a successful login message
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user visits the index
    Then the user will see a consent request

@javascript
  Scenario: (Bingo)User should be presented with an unpresented course consent form if one exists
    #Disable the project
    Given the project started "two months hence" and ends "three months hence", opened "yesterday" and closes "tomorrow"
    #Create the Bingo
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 7
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! "has" been activated

    When the user logs in
    Then the user should see a successful login message
    # Build the consent form
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested

    When the user visits the index
    Then the user will see a consent request

@javascript
  Scenario: (Experience)User should be presented with an unpresented course consent form if one exists
    #Disable the project
    Given the project started "two months hence" and ends "three months hence", opened "yesterday" and closes "tomorrow"
    #Create the Experience
    Given there is a course with an experience
    Given the experience "has" been activated
    When the user logs in
    Then the user should see a successful login message

    # Build the consent form
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested

    When the user visits the index
    Then the user will see a consent request

@javascript
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

@javascript
  Scenario: User should be presented with an unpresented global consent form if one exists
    When the user logs in
    Then the user should see a successful login message
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given there is a global consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has not" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user visits the index
    Then the user will see a consent request

@javascript
  Scenario: User should be presented with an unpresented global and project consent form if one exists
    When the user logs in
    Then the user should see a successful login message
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
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

  @javascript
  Scenario: User should be able to access a presented consent form, but not be redirected to it
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then the user switches to the "Task View" tab
    Then user should see 1 open task
    Then the user enables the "Consent Form" table view option
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form

  @javascript
  Scenario: If no consent form is attached to an assessment, none should be presented
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then the user switches to the "Task View" tab
    Then user should see 1 open task
    Then the user enables the "Consent Form" table view option
    Then user should not see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form

  @javascript
  Scenario: If an inactive consent form is attached to an assessment, none should be presented
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has been activated
    Given the user "has" had demographics requested
    Given there is a global consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is not" active
    Given the consent form "has not" been presented to the user
    When the user logs in
    Then the user should see a successful login message
    Then the user switches to the "Task View" tab
    Then user should see 1 open task
    Then the user enables the "Consent Form" table view option
    Then user should not see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form

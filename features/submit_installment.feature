Feature: Submitting Reports
  Students must be able to reach and complete their weekly installments

  Background:
    Given there is a course with an assessed project
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users
    Given reset time clock to now
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"

  @javascript
  Scenario: User should be able to complete an open weekly installment
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
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
    Then the installment form should request factor x user values
    Then the user should enter values summing to 6000, "evenly" across each column
    When the user submits the installment
    Then the installment will successfully save
    Then user opens their profile
    Then user sees the assessed project in the history
    Then the installment values will match the submit ratio

  @javascript
  Scenario: User should be able to complete an open weekly installment with a comment
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
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
    Then the installment form should request factor x user values
    Then the user should enter values summing to 6000, "evenly" across each column
    Then the user enters a comment "with" personally identifiable information
    When the user submits the installment
    Then the installment will successfully save
    Then user opens their profile
    Then user sees the assessed project in the history
    Then the comment matches what was entered
    Then the anonymous comment "is empty"
    Then the installment values will match the submit ratio

  @javascript
  Scenario: User should not be able to edit a completed weekly installment
    Given the project measures 4 factors
    Given the project has a group with 4 confirmed users
    Given the course has a consent form
    Given the user is the "last" user in the group
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Then the user logs in and submits an installment
    When the user navigates home
    Then the user switches to the "Task View" tab
    Then the user enables the "Status" table view option
    Then the assessment should show up as completed
    Then the installment values will match the submit ratio

  @javascript
  Scenario: An installment's factor values can all be set to 0
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
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
    Then the installment form should request factor x user values
    Then the user should enter values summing to 0, "evenly" across each column
    When the user submits the installment
    Then the installment will successfully save
    Then the installment values will match the submit ratio

  @javascript
  Scenario: An installment's factor values can be randomly assigned
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Consent Form" table view option
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 6000, "randomly" across each column
    When the user submits the installment
    Then the installment will successfully save
    Then the installment values will match the submit ratio

  @javascript
  Scenario: A installment's factor column need not sum to 600 or be distributed evenly
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
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
    Then the installment form should request factor x user values
    Then the user should enter values summing to 6549, "randomly" across each column
    When the user submits the installment
    Then the installment will successfully save
    Then the installment values will match the submit ratio

  @javascript
  Scenario: A installment's factor column need not sum to 6000
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
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
    Then the installment form should request factor x user values
    Then the user should enter values summing to 1200, "evenly" across each column
    When the user submits the installment
    Then the installment will successfully save
    Then the installment values will match the submit ratio

  @javascript
  Scenario: User should not be able to submit an installment after the assessment has closed
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    Given today is "tomorrow 23:57"
    When the user logs in
    Then the user should see a successful login message
    Then the user switches to the "Task View" tab
    Then user should see 1 open task
    Then the user enables the "Consent Form" table view option
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 600, "evenly" across each column
    Given today is "in 10 minutes"
    When the user submits the installment
    Then the user should see an error indicating that the installment request expired

  @javascript
  Scenario: Comments with PII should be anonymized when the assessment period closes
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
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
    Then the installment form should request factor x user values
    Then the user should enter values summing to 6000, "evenly" across each column
    Then the user enters a comment "with" personally identifiable information
    When the user submits the installment
    Then the installment will successfully save
    Then user opens their profile
    Then user sees the assessed project in the history
    Then the comment matches what was entered
    Then the anonymous comment "is empty"
    Then the installment values will match the submit ratio
    Given today is "3 days hence"
    Given the email queue is empty
    Then the system emails instructor reports
    Then 1 emails will be sent
    Then the comment matches what was entered
    Then the anonymous comment "is anonymized"

  @javascript
  Scenario: Comments without PII should not be anonymized when the assessment period closes
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Given the user "has" had demographics requested
    When the user logs in
    Then the user should see a successful login message
    Then the user switches to the "Task View" tab
    Then the user enables the "Consent Form" table view option
    Then user should see 1 open task
    Then user should see a consent form listed for the open project
    When user clicks the link to the project
    Then user will be presented with the installment form
    Then the installment form should request factor x user values
    Then the user should enter values summing to 6000, "evenly" across each column
    Then the user enters a comment "without" personally identifiable information
    When the user submits the installment
    Then the installment will successfully save
    Then user opens their profile
    Then user sees the assessed project in the history
    Then the comment matches what was entered
    Then the anonymous comment "is empty"
    Then the installment values will match the submit ratio
    Given today is "3 days hence"
    Given the email queue is empty
    Then the system emails instructor reports
    Then 1 emails will be sent
    Then the comment matches what was entered
    Then the anonymous comment "matches"

Feature: Experience Listing
  In order to provide us with their review data,
  Students must be able to see what experience.
  are due.

  Background:
    Given there is a course with an experience
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested

@javascript
  Scenario: Checking for open experiences
    Given the experience started "last month" and ends "2 months hence"
    Given the experience "has" been activated
    Given the user is "a random" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user logs out
    Given the user is "the first" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user logs out

@javascript
  Scenario: A student that drops the course won't see the experience
    Given the experience started "last month" and ends "2 months hence"
    Given the experience "has" been activated
    Given the user is "a random" user
    Then the user is dropped from the course
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task

@javascript
  Scenario: We shouldn't see an experience that's not active
    Given the experience "has not" been activated
    Given the experience started "last month" and ends "2 months hence"
    Given the experience "has not" been activated
    Given the user is "a random" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task

@javascript
  Scenario: We shouldn't see an experience in instructor prep
    Given the experience "has not" been activated
    Given the experience started "last month" and ends "3 days hence"
    Given the experience 'lead_time' is 2
    Given the experience "has not" been activated
    Given the user is "a random" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task

@javascript
  Scenario: Checking for experiences with opening today and closing tomorrow
    Given the experience started "today" and ends "tomorrow"
    Given the experience 'lead_time' is 0
    Given the experience "has" been activated
    Given the user is "a random" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    
@javascript
  Scenario: Checking for experiences with one outside the date range
    Given the experience started "2 months ago" and ends "last month"
    Given the experience "has" been activated
    Given the user is "a random" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task
    
@javascript
  Scenario: Checking for assessments and projects together
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience 'lead_time' is 0
    Given the experience "has" been activated
    Given the user is "a random" user
    Given the course has an assessed project
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the user is in a group on the project
    Given the factor pack is set to "Original"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 2 open task

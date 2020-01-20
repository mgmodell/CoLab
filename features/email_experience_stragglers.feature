Feature: Email experience stragglers
  In order to make sure we get complete information,
  Students must be reminded to complete their experiences.

  Background:
    Given there is a course with an experience
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the experience started "last month" and ends "in two months"
    Given the experience "has" been activated

  Scenario: Four students have experiences waiting when we email the stragglers - four emails are sent
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked

  Scenario: 4 students are invited and one student drops - 3 emails are sent
    Given the email queue is empty
    Given the user is "a random" user
    Then the user is dropped from the course
    When the system emails stragglers
    Then 3 emails will be sent
    Then 3 emails will be tracked

  Scenario: Four students have incomplete experiences that ended yesterday - no emails are sent
    Given the experience started "last month" and ends "yesterday"
    Given the experience "has" been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked

  Scenario: 4 Ss incomplete; experience ends in 2 days, 2 days lead time - no emails are sent
    Given the experience started "last month" and ends "two days hence"
    Given the experience 'lead_time' is 2
    Given the experience "has" been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked

@javascript
  Scenario: 1 student completes an experience
    Given the user is "a random" user
    When the user logs in
    Then the user successfully completes an experience
    Given the email queue is empty
    When the system emails stragglers
    Then 3 emails will be sent
    Then 3 emails will be tracked

  Scenario: 1 user is in an experience and a project they receive only one email
    Given the user is "a random" user
    Given there is a course with an assessed project
    Given the user is in a group on the project with 3 other users
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    Given the project has been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 7 emails will be sent
    Then 7 emails will be tracked

  Scenario: 4 users is in an experience and 4 in a project they each receive only one email
    Given the user is "a random" user
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    Given the project has been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 8 emails will be sent
    Then 8 emails will be tracked

  @javascript
  Scenario: 1 user is in an experience and a project they receive only one email
    Given the user is "a random" user
    Given there is a course with an assessed project
    Given the user is in a group on the project with 3 other users
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    Given the project has been activated
    When the user logs in
    Then the user successfully completes an experience
    Then the user logs out
    Given the email queue is empty
    When the system emails stragglers
    Then 7 emails will be sent
    Then 7 emails will be tracked

  @javascript
  Scenario: 1 user is in an experience and a project they receive only one email
    Given the user is "a random" user
    Given there is a course with an assessed project
    Given the user is in a group on the project with 3 other users
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    Given the project has been activated
    When the user logs in
    Then the user successfully completes an experience
    Then the user logs out
    Then the user logs in and submits an installment
    Given the email queue is empty
    When the system emails stragglers
    Then 6 emails will be sent
    Then 6 emails will be tracked

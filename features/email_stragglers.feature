Feature: Email stragglers
  In order to make sure we get complete information,
  Students must be reminded to complete their assessments.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"

  Scenario: Four students have assessments waiting when we email the stragglers - four emails are sent
    Given the email queue is empty
    Given the user is the "last" user
    Given the project has been activated
    When the system emails stragglers
    Then an email will be sent to each member of the group

  Scenario: Three students have open assessments waiting when we email the stragglers, but one does not - three emails are sent
    Given the email queue is empty
    Given the project measures 4 factors
    Given the project has a consent form
    Given the user is the "last" user
    Given the consent form "has" been presented to the user
    Given the project has been activated
    Then the user logs in and submits an installment
    When the system emails stragglers
    Then an email will be sent to each member of the group but one

  Scenario: Four students have been mailed about their assessments waiting when we email the stragglers - no emails are sent
    Given the email queue is empty
    Given the user is the "last" user
    Given the project has been activated
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Given the email queue is empty
    When the system emails stragglers
    Then no emails will be sent

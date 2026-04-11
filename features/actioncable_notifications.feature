Feature: ActionCable notifications for peer assessments and in-app alerts
  Students should receive real-time notifications when peers submit their
  peer-assessment installments, and all users should receive in-app alerts
  when activities become available or pending activities are outstanding.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project measures 3 factors
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
    Given the consent form "has" been presented to the user
    Given the project has been activated

  # ------------------------------------------------------------------
  # Item 6 – InstallmentChannel broadcasts
  # ------------------------------------------------------------------

  Scenario: Saving an installment broadcasts a group notification
    Given reset time clock to now
    When a group member saves their installment
    Then the installment channel should have received a broadcast for the group

  Scenario: Broadcast payload contains required fields
    Given reset time clock to now
    When a group member saves their installment
    Then the installment broadcast payload should contain the submitter's details

  Scenario: Only one broadcast is sent per installment save
    Given reset time clock to now
    When a group member saves their installment
    Then exactly 1 broadcast should be sent to the installment channel

  # ------------------------------------------------------------------
  # Item 7 – NotificationsChannel broadcasts
  # ------------------------------------------------------------------

  Scenario: Sending reminder emails also broadcasts in-app notifications
    Given the email queue is empty
    When the system emails stragglers
    Then in-app reminder notifications should have been broadcast to each eligible user

  Scenario: notify_availability broadcasts an in-app notification alongside the email
    Given reset time clock to now
    When an activity is marked available for the user
    Then an in-app availability notification should have been broadcast to the user

Feature: Email experience stragglers
  In order to make sure we get complete information,
  Students must be reminded to complete their assessments.

  Background:
    Given there is a course with an experience
    Given the course has one instructor
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the experience started "last month" and ends "next month"
    Given the experience "has" been activated

  Scenario: Course Instructor will be emailed when experience closes
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Given today is "32 days from now"
    Given the email queue is empty
    Then 1 emails will be sent

  Scenario: Both Course Instructors will be emailed when experience closes
    Given the course has one instructor
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Given today is "32 days from now"
    Given the email queue is empty
    Then 2 emails will be sent

  Scenario: Check project reports

  Scenario: Check Bingo! reports

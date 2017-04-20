Feature: Email experience stragglers
  In order to make sure we get complete information,
  Students must be reminded to complete their assessments.

  Background:
    Given there is a course with an experience
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course

  Scenario: Course Instructor will be emailed when experience closes
    Given the experience started "last month" and ends "3 days from now"
    Given the experience "has" been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent

  Scenario: Both Course Instructors will be emailed when experience closes
    Given the experience started "last month" and ends "3 days from now"
    Given the experience "has" been activated
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Given today is "32 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 2 emails will be sent

  Scenario: Check project reports

  Scenario: Check Bingo! reports

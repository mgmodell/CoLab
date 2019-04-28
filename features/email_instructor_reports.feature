Feature: Email experience stragglers
  In order to make sure we get complete information,
  Students must be reminded to complete their assessments.

  Background:
    Given there is a course
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course

  @javascript
  Scenario: Instructor emailed when bingo closes and students responded
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated

    #set up the users and have them complete the bingo! prep assignment
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as a group"
    # 36 terms
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as individuals"
    # 40 terms
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as individuals"
    # 20
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as a group"
    # 18
    Given the project has a group with 4 confirmed users
    Given the users "don't" prep "as a group"
    # 0
    Given the course has 4 confirmed users
    Given the users "incomplete" prep "as individuals"
    # 20

    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course

    Given the email queue is empty
    Then the system emails stragglers
    When the system emails stragglers
    Given today is "1 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 1 emails will be tracked

  Scenario: Course Instructor will be emailed when experience closes
    Given the course has an experience
    Given the experience started "last month" and ends "4 days from now"
    Given the experience "has" been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 5 emails will be tracked

  Scenario: Instructor not emailed when experience end_date changes before today
    Given the course has an experience
    Given the experience started "last month" and ends "4 days from now"
    Given the experience "has" been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 5 emails will be tracked
    Then the experience started "last month" and ends "3 days from now"
     And the experience 'lead_time' is 2
    Given the email queue is empty
    When the system emails instructor reports
    Then 0 emails will be sent
    Then 5 emails will be tracked

  Scenario: Instructor emailed when experience end date changes after today
    Given the course has an experience
    Given the experience started "last month" and ends "4 days from now"
    Given the experience "has" been activated
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 5 emails will be tracked
    Then the experience started "last month" and ends "15 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 0 emails will be sent
    Then 5 emails will be tracked
    Given today is "30 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 6 emails will be tracked

  Scenario: Both Course Instructors will be emailed when experience closes
    Given the course has an experience
    Given the experience started "last month" and ends "4 days from now"
    Given the experience "has" been activated
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    Given the email queue is empty
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked
    Given today is "32 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 2 emails will be sent
    Then 6 emails will be tracked

  Scenario: Check project reports
    Given the course has an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    Given the project has been activated
    Given the email queue is empty
    Then the system emails stragglers
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 5 emails will be tracked

  Scenario: Check project reports when a student has completed an assessment
    Given the course has an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    Given the project has been activated
    Given the email queue is empty
    Given the user is the "last" user in the group
    Then the user logs in and submits an installment
    Then the system emails stragglers
    When the system emails stragglers
    Then 3 emails will be sent
    Then 3 emails will be tracked
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 4 emails will be tracked

  Scenario: Both Course Instructors will be emailed when the project assessment closes
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    Given the course has an assessed project
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    Given the factor pack is set to "Original"
    Given the project has been activated
    Given the email queue is empty
    Then the system emails stragglers
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked
    Given today is "4 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 2 emails will be sent
    Then 6 emails will be tracked

  Scenario: Course Instructor will be emailed when bingo closes
    Given the course has a Bingo! game
    Given the course has an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated

    Given the email queue is empty
    When the system emails stragglers
    Given today is "1 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 1 emails will be tracked

  Scenario: Instructor not emailed when bingo closes and end date changed earlier
    Given the course has a Bingo! game
    Given the course has an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated

    Given the email queue is empty
    When the system emails stragglers
    Given today is "1 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 1 emails will be tracked

    # Change the end date
    Given the Bingo! started "last month" and ends "1 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 0 emails will be sent
    Then 1 emails will be tracked

  Scenario: Instructor emailed when bingo closes and end date changed later
    Given the course has a Bingo! game
    Given the course has an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated

    Given the email queue is empty
    When the system emails stragglers
    Given today is "1 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 1 emails will be tracked

    # Change the end date
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 0 emails will be sent
    Then 1 emails will be tracked

    #Advance the clock
    Given today is "2 days from now"
    Given the email queue is empty
    When the system emails instructor reports
    Then 1 emails will be sent
    Then 2 emails will be tracked

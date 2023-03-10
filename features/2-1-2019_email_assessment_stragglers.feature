Feature: Email assessment stragglers (for 2/1/2019 date)
  In order to make sure we get complete information,
  Students must be reminded to complete their assessments.

  Background:
    Given today is "February 1, 2019"
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"

  Scenario: Four students have assessments waiting when we email the stragglers - four emails are sent
    Given the email queue is empty
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"
    Given the project has been activated
    When the system emails stragglers
    Then 4 emails will be sent
    Then 4 emails will be tracked

  Scenario: 4 students have assessments waiting. 1 drops the course. Email the stragglers - 3 emails are sent
    Given the email queue is empty
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"
    Given the project has been activated
    Then the user is dropped from the course
    When the system emails stragglers
    Then 3 emails will be sent
    Then 3 emails will be tracked

  @javascript
  Scenario: Three students have open assessments waiting when we email the stragglers, but one does not - three emails are sent
    Given the email queue is empty
    Given the project measures 4 factors
    Given the course has a consent form
    Given the user is the "last" user in the group
    Given the consent form "has" been presented to the user
    Given the factor pack is set to "Original"
    Given the project has been activated
    Then the user logs in and submits an installment
    When the system emails stragglers
    Then an email will be sent to each member of the group but one

  Scenario: Four students have been mailed about their assessments waiting when we email the stragglers - no emails are sent
    Given the email queue is empty
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"
    Given the project has been activated
    When the system emails stragglers
    Given the project has been activated
    Then an email will be sent to each member of the group
    Then 4 emails will be tracked
    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 4 emails will be tracked

  Scenario: 4 students are in a project, but the project has been deactivated - no emails are sent
    Given the email queue is empty
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"
    Given the project has been activated
    Given the project has been deactivated
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked

  Scenario: 2 groups of 4 students and 1 group of 2. Group of 2 disbands and members split. 10 emails sent
    Given the project has a group with 4 confirmed users
    Given the project has a group with 2 confirmed users
    Given the factor pack is set to "Original"
    Given the project has been activated

    Then the members of "the last" group go to other groups

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked
    Given the project has been activated
    When the system emails stragglers
    Then 10 emails will be sent
    Then 10 emails will be tracked

  Scenario: 2 groups of 4 students. 1 group of 2 added in week 2 - 10 emails sent in week 2
    Given the project started "two months ago" and ends "30 days from now", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    Given the factor pack is set to "Original"

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked
    Given the project has been activated
    When the system emails stragglers
    Then 8 emails will be sent
    Then 8 emails will be tracked

    Given today is "7 days from now"
    #This should deactivate the project
    Given the project has a group with 2 confirmed users

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 8 emails will be tracked
    Given the project has been activated
    When the system emails stragglers
    Then 10 emails will be sent
    Then 18 emails will be tracked

    Given today is "10 days from now"
    Given the project has a group with 4 confirmed users
    Given today is "4 days from now"

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 18 emails will be tracked
    # This is the final round for this one.
    Given the project has been activated
    When the system emails stragglers
    Then 14 emails will be sent
    Then 32 emails will be tracked

  Scenario: 2 groups of 4 students and 1 group of 2. Group of 2 disbands in second week - 10 emails sent
    Given the project has a group with 4 confirmed users
    Given the project has a group with 2 confirmed users
    Given the factor pack is set to "Original"

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked
    Given the project has been activated
    When the system emails stragglers
    Then 10 emails will be sent
    Then 10 emails will be tracked

    Given today is "7 days from now"

    Then the members of "the last" group go to other groups

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 10 emails will be tracked
    Given the project has been activated
    When the system emails stragglers
    Then 10 emails will be sent
    Then 20 emails will be tracked

  Scenario: 2 groups of 4 students and 1 group of 2. Group of 2 disbands in second week - 10 emails sent
    Given the project has a group with 4 confirmed users
    Given the project has a group with 2 confirmed users
    Given the factor pack is set to "Original"

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Given the project has been activated
    When the system emails stragglers
    Then 10 emails will be sent

    #Let's add a new group mid-stream
    Given the project has a group with 2 confirmed users
    Then 10 emails will be sent
    When the system emails stragglers
    Then 10 emails will be sent
    Then 10 emails will be tracked

    Given the project has been activated
    When the system emails stragglers
    Then 12 emails will be sent
    Then 12 emails will be tracked

    Given today is "7 days from now"

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 12 emails will be tracked
    Given the project has been activated
    When the system emails stragglers
    Then 12 emails will be sent
    Then 24 emails will be tracked

  Scenario: Mess with running the set_up_assessments process
    Given the project has a group with 4 confirmed users
    Given the project has a group with 2 confirmed users
    Given the factor pack is set to "Original"

    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 0 emails will be tracked
    Given the project has been activated
    #The project should be available
    When the system emails stragglers
    Then 10 emails will be sent
    Then 10 emails will be tracked
    Then that the system's set_up_assessments process runs
    When the system emails stragglers
    Then 10 emails will be sent
    Then 10 emails will be tracked
    Given today is "1 day from now"
    #The project should be available
    Then that the system's set_up_assessments process runs
    When the system emails stragglers
    Then 20 emails will be sent
    Then 20 emails will be tracked

    #Add a new group
    Given the email queue is empty
    Given today is "3 days from now"
    #The project should NOT be available
    Given the project has a group with 2 confirmed users
    Given the project has been activated
    Then that the system's set_up_assessments process runs
    When the system emails stragglers
    Then 0 emails will be sent
    Then 20 emails will be tracked

    Given today is "4 days from now"
    Then that the system's set_up_assessments process runs
    When the system emails stragglers
    Then 12 emails will be sent
    Then 32 emails will be tracked

    Then the members of "a random" group go to other groups
    Then the project has been activated

    Given today is "7 days from now"
    Given the email queue is empty
    When the system emails stragglers
    Then 0 emails will be sent
    Then 32 emails will be tracked
    #The setup process has to run or we don't have an open assessment
    Then that the system's set_up_assessments process runs
    When the system emails stragglers
    Then 12 emails will be sent
    Then 44 emails will be tracked


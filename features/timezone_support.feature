Feature: Timezone Support
  In order to provide us with their review data,
  Students must be able to see what project assessments 
  are due.

  Background:
    #March 8, 1980 was a Saturday
    Given today is "March 8, 1980"
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the user is the "last" user
    Given the user "has" had demographics requested
    Given the email queue is empty

  Scenario: Checking for open projects
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 12:00am UTC"
    Then the user should see "Sun, Mar 9 at 11:59pm UTC"
    Then return to the present
    
  Scenario: Checking that open projects reflect my timezone
    Given the user timezone is "Seoul"
    Given the course timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 9:00am KST"
    Then the user should see "Mon, Mar 10 at 8:59am KST"
    Then return to the present
    
  Scenario: Projects times should reflect course timezones
    Given the user timezone is "UTC"
    Given the course timezone is "Seoul"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 9:00am UTC"
    Then the user should see "Mon, Mar 10 at 8:59am UTC"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Then return to the present
    
  Scenario: Projects shouldn't open too soon
    Given today is "March 5, 1980 at 8:59am"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open project
    When the system emails stragglers
    When the system emails stragglers
    Then no emails will be sent
    Then return to the present
    
  Scenario: Projects times should open at exactly the correct time
    Given today is "March 7, 1980 at 9:01am"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 9:00am UTC"
    Then the user should see "Mon, Mar 10 at 8:59am UTC"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Then return to the present
    
  Scenario: Projects times should accurately reflect course timezones
    Given today is "March 5, 1980 at 3:01pm"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Wed, Mar 5 at 3:00pm UTC"
    Then the user should see "Sun, Mar 9 at 2:59pm UTC"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Given the email queue is empty
    Given today is "24 hours from now"
    Given that the system's set_up_assessments process runs
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Then return to the present

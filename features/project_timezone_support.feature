Feature: Timezone Support
  In order to provide us with their review data,
  Students must be able to see what project assessments 
  are due.

  Background:
    #March 8, 1980 was a Saturday
    Given today is "March 8, 1980"
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the user is the "last" user in the group
    Given the user timezone is "UTC"
    Given the user "has" had demographics requested
    Given the factor pack is set to "Original"
    Given the email queue is empty

  @javascript
  Scenario: Checking for open projects
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Mar 7, 1980, 12:00 AM"
    Then the user enables the "Close Date" table view option
    Then the user should see "Mar 9, 1980, 11:59 PM"
    
  @javascript
  Scenario: Checking that open projects reflect my timezone
    Given the user timezone is "Seoul"
    Given the course timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Mar 7, 1980, 9:00 AM"
    Then the user should see "Mar 10, 1980, 8:59 AM"
    
  @javascript
  Scenario: Projects shouldn't open too soon
    Given today is "March 5, 1980 at 8:59am"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task
    When the system emails stragglers
    When the system emails stragglers
    Then 0 emails will be sent
    
  @javascript
  Scenario: Projects times should reflect course timezones - New York
    Given the course timezone is "America/New_York"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Mar 7, 1980, 5:00 AM"
    Then the user should see "Mar 10, 1980, 4:59 AM"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    
  @javascript
  Scenario: Projects times should reflect course timezones - Seoul
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Mar 6, 1980, 3:00 PM"
    Then the user should see "Mar 9, 1980, 2:59 PM"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    
  @javascript
  Scenario: Projects times should open at exactly the correct time
    Given today is "March 7, 1980 at 9:01am"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Mar 6, 1980, 3:00 PM"
    Then the user should see "Mar 9, 1980, 2:59 PM"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    
  @javascript
  Scenario: Only one email should be sent out per person per day.
    Given today is "March 7, 1980 at 9:01am"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Mar 6, 1980, 3:00 PM"
    Then the user should see "Mar 9, 1980, 2:59 PM"
    When the system emails stragglers
    When the system emails stragglers
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Given today is "6 hours from now"
    When the system emails stragglers
    Then an email will be sent to each member of the group
    Given today is "6 hours from now"
    Given the email queue is empty
    Given today is "24 hours from now"
    Given that the system's set_up_assessments process runs
    When the system emails stragglers
    Then an email will be sent to each member of the group
    
@javascript
  Scenario: Only one assessment per project per week
    Given the course timezone is "Seoul"
    Given the user timezone is "Seoul"
    Given the project has a group with 4 confirmed users
    Given the user is the "a random" user in the group
    Given the user "has" had demographics requested

    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Monday"
    Given the project has been activated

    #Loop - every hour for 5 days
    When the user logs in
    Given today is "March 5, 1980 at 3:00pm"
    Given the user sees 0 assessment every hour of the day
    Given today is "March 6, 1980 at 3:00pm"
    Given the user sees 1 assessment every hour of the day
    Given today is "March 7, 1980 at 3:00pm"
    Given the user sees 1 assessment every hour of the day
    Given today is "March 8, 1980 at 3:00pm"
    Given the user sees 1 assessment every hour of the day
    Given today is "March 9, 1980 at 3:00pm"
    Given the user sees 1 assessment every hour of the day
    Given today is "March 10, 1980 at 3:00pm"
    Given the user sees 0 assessment every hour of the day
    Given today is "March 11, 1980 at 3:00pm"
    Given the user sees 0 assessment every hour of the day
    Given today is "March 12, 1980 at 3:00pm"
    Given the user sees 0 assessment every hour of the day
    Given today is "March 13, 1980 at 3:00pm"
    Given the user sees 1 assessment every hour of the day
    Given today is "March 14, 1980 at 3:00pm"
    Given the user sees 1 assessment every hour of the day
    

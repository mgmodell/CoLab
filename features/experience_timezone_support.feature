Feature: Timezone Support for Experiences
  In order to provide us with their review data,
  Students must be able to see what project assessments 
  are due.

  Background:
    #March 8, 1980 was a Saturday
    Given today is "March 8, 1980"
    Given there is a course with an experience
    Given the experience started "February 15, 1980" and ends "April 15, 1980"
    Given the experience 'lead_time' is 2
    Given the experience "has" been activated
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the user is "a random" user
    Given the email queue is empty

@javascript
  Scenario: Checking for open experiences bears correct time
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user should see "Feb 15, 1980, 12:00 AM"
    #Rounding goes on here
    Then the user should see "Apr 12, 1980, 11:59 PM"
    
@javascript
  Scenario: Checking that open projects reflect my timezone
    Given the user timezone is "Seoul"
    Given the course timezone is "UTC"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user should see "Feb 15, 1980, 9:00 AM"
    Then the user should see "Apr 13, 1980, 8:59 AM"
    
@javascript
  Scenario: Projects shouldn't open too soon
    Given today is "February 14, 1980 at 2:59pm"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task
    
@javascript
  Scenario: Projects times should reflect course timezones - New York
    Given the course timezone is "America/New_York"
    Given the user timezone is "UTC"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user should see "Feb 15, 1980, 5:00 AM"
    Then the user should see "Apr 13, 1980, 4:59 AM"
    

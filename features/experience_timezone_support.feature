Feature: Timezone Support for Experiences
  In order to provide us with their review data,
  Students must be able to see what project assessments 
  are due.

  Background:
    #March 8, 1980 was a Saturday
    Given today is "March 8, 1980"
    Given there is a course with an experience
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the user is "a random" user
    Given the email queue is empty

  Scenario: Checking for open experiences bears correct time
    Given the experience started "February 15, 1980" and ends "April 15, 1980"
    Given the experience has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user should see "Fri, Feb 15 at 12:00am UTC"
    Then the user should see "Tue, Apr 15 at 11:59pm UTC"
    Then return to the present
    
  Scenario: Checking that open projects reflect my timezone
    Given the user timezone is "Seoul"
    Given the course timezone is "UTC"
    Given the experience started "February 15, 1980" and ends "April 15, 1980"
    Given the experience has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user should see "Fri, Feb 15 at 9:00am KST"
    Then the user should see "Wed, Apr 16 at 8:59am KST"
    Then return to the present
    
  Scenario: Projects shouldn't open too soon
    Given today is "February 14, 1980 at 2:59pm"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    Given the experience started "February 15, 1980" and ends "April 15, 1980"
    Given the experience has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task
    Then return to the present
    
  Scenario: Projects times should reflect course timezones - New York
    Given the course timezone is "America/New_York"
    Given the user timezone is "UTC"
    Given the experience started "February 15, 1980" and ends "April 15, 1980"
    Given the experience has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user should see "Fri, Feb 15 at 5:00am UTC"
    Then the user should see "Wed, Apr 16 at 4:59am UTC"
    Then return to the present
    

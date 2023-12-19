Feature: Timezone Support for Bingo!
  In order to provide us with their review data,
  Students must be able to see what bingo games
  are due.

  Background:
    #March 8, 1980 was a Saturday
    Given today is "March 8, 1980"
    Given there is a course with an assessed project
    Given the course has a Bingo! game
    Given the bingo started "February 15, 1980" and ends "April 15, 1980"
    Given the Bingo! "has" been activated
    Given the course has 4 confirmed users
    Given the users "have" had demographics requested
    Given the user is "a random" user
    Given the email queue is empty

  @javascript
  Scenario: Checking for open bingo bears correct time
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option

    Then the user should see "Feb 15, 1980, 12:00 AM"
    #Rounding goes on here
    Then the user enables the "Close Date" table view option
    Then the user should see "Apr 12, 1980, 11:59 PM"
    
  @javascript
  Scenario: Checking that open bingos reflect my timezone
    Given the user timezone is "Seoul"
    Given the course timezone is "UTC"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Feb 15, 1980, 9:00 AM"
    Then the user enables the "Close Date" table view option
    Then the user should see "Apr 13, 1980, 8:59 AM"
    
@javascript
  Scenario: Bingos shouldn't open too soon
    Given today is "February 14, 1980 at 2:59pm"
    Given the course timezone is "Seoul"
    Given the user timezone is "UTC"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task
    
  @javascript
  Scenario: Bingo times should reflect course timezones - New York
    Given the course timezone is "America/New_York"
    Given the user timezone is "UTC"
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user switches to the "Task View" tab
    Then the user enables the "Open Date" table view option
    Then the user should see "Feb 15, 1980, 5:00 AM"
    Then the user enables the "Close Date" table view option
    Then the user should see "Apr 13, 1980, 4:59 AM"
    

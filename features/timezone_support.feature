Feature: Assessment Listing
  In order to provide us with their review data,
  Students must be able to see what project assessments 
  are due.

  Background:
    #Martch 8, 1980 was a Saturday
    Given today is "March 8, 1980"
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the user is the "last" user
    Given the user "has" had demographics requested

  Scenario: Checking for open projects
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, 07 Mar 1980 00:00:00 +0000"
    Then the user should see "Sun, 09 Mar 1980 23:59:59 +0000"
    
  Scenario: Checking for open projects
    Given the user timezone is "Seoul"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, 07 Mar 1980 09:00:00 +0900"
    Then the user should see "Mon, 10 Mar 1980 08:59:59 +0900"
    


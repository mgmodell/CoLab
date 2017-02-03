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
    Given the email queue is empty

  Scenario: Checking for open projects
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 12:00am UTC"
    Then the user should see "Sun, Mar 9 at 11:59pm UTC"
    
  Scenario: Checking for open projects
    Given the user timezone is "Seoul"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 9:00am KST"
    Then the user should see "Tue, Mar 11 at 8:59am KST"
    
  Scenario: Projects shouldn't open too soon
    Given the user timezone is "Seoul"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 9:00am KST"
    Then the user should see "Tue, Mar 11 at 8:59am KST"
    
  Scenario: Stragglers shouldn't be emailed too soon
    Given the user timezone is "Seoul"
    Given the project started "February 15, 1980" and ends "April 15, 1980", opened "Friday" and closes "Sunday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open project
    Then the user should see "Fri, Mar 7 at 9:00am KST"
    Then the user should see "Tue, Mar 11 at 8:59am KST"
    


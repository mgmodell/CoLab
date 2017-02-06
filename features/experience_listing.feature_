Feature: Assessment Listing
  In order to provide us with their review data,
  Students must be able to see what project assessments 
  are due.

  Background:
    Given there is a course with an experience
    Given the experience has been activated
    Given the course has 4 confirmed users
    Given the user is the "last" user
    Given the user "has" had demographics requested

  Scenario: Checking for open projects
    Given the experience started "last month" and ends "next month"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task

  Scenario: Checking for projects with opening and closing today
    Given the project started "last month" and ends "next month", opened "today" and closes "today"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    
  Scenario: Checking for projects with one outside the date range
    Given the project started "2 months ago" and ends "last month", opened "yesterday" and closes "tomorrow"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task
    
  Scenario: Checking for projects with one outside the day range ( not crossing sat/sun)
    Given the project started "last month" and ends "next month", opened "2 days ago" and closes "yesterday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task

  Scenario: Checking for assessments with one outside the day range (crossing sat/sun)
    Given the project started "last month" and ends "next month", opened "tomorrow" and closes "yesterday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task

  Scenario: Checking for assessments with one starting today and ending yesterday
    Given the project started "last month" and ends "next month", opened "today" and closes "yesterday"
    Given the project has been activated
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task

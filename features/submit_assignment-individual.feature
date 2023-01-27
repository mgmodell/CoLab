Feature: (Re)Submitting individual assignments
  Students must be able to (re)submit individual assignments

  Background:
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has an assignment
    Given the assignment "is not" group-capable
    Given the assignment's first deadline is "2/29/1980" and final is "7/10/2008"
    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    Given the assignment "is" active
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested

  Scenario: User should not be able to see an inactive assignment
    Given the assignment "is" active
    Given the user logs in
    Then user should see 0 open task

  Scenario: User should not be able to see a closed assignment
  Scenario: User can see the assginment's attached rubric
  Scenario: User can open and submit text to an assignment
  Scenario: User can open and submit a file to an assignment
  Scenario: User can open and submit a link to an assignment
  Scenario: User can open and submit files to an assignment
  Scenario: User can open and submit links to an assignment
  Scenario: User can open and submit a combo to an assignment
  Scenario: User can submit a combo to an assignment before the first deadline
  Scenario: User can submit a combo to an assignment after the first deadline but before the final
  Scenario: User cannot submit to an assignment after the final deadline
  Scenario: User can submit and re-submit text" to an assignment
  Scenario: User can submit and re-submit a file to an assignment
  Scenario: User can submit and re-submit a link to an assignment
  Scenario: User can submit and re-submit a combo to an assignment
  Scenario: User can withdraw a submitted assignment


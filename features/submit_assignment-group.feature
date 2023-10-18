Feature: (Re)Submitting individual assignments
  Students must be able to (re)submit individual assignments

  Background:
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has an assignment
    Given the assignment "is" initialised as group-capable
    Given the assignment opening is "one month ago" and close is "one month from now"
    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    Given the assignment "is" active
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested

  Scenario: User should not be able to see an inactive assignment
    Given the assignment "is" active
    Given the user logs in
    Then user should see 0 open task

  Scenario: User should not be able to see a closed group assignment
  Scenario: Group members can see the assginment's attached rubric
  Scenario: Group member can open and submit text to a group assignment
  Scenario: Group member can open and submit a file to a group assignment
  Scenario: Group member can open and submit a link to a group assignment
  Scenario: Group member can open and submit files to a group assignment
  Scenario: Group member can open and submit links to a group assignment
  Scenario: User can open and submit a combo to a group assignment
  Scenario: User can submit a combo to a group assignment before the first deadline
  Scenario: User can submit a combo to a group assignment after the first deadline but before the final
  Scenario: User cannot submit to a group assignment after the final deadline
  Scenario: Different users can submit and re-submit text" to a group assignment
  Scenario: Different users can submit and re-submit a file to a group assignment
  Scenario: Different users can submit and re-submit a link to a group assignment
  Scenario: Different users can submit and re-submit a combo to a group assignment
  Scenario: Different users can submit then withdraw a submitted assignment


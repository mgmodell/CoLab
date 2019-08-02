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
    Given the assignment "is" group-capable
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

  Scenario: User should not be able to see a closed group assignment
  Scenario: Group members can see the assginment's attached rubric
  Scenario: Group member can open and submit text to a group assignment
  Scenario: Group member can open and submit a file to a group assignment
  Scenario: Group member can open and submit a link to a group assignment
  Scenario: User can open and submit a combo to a group assignment
  Scenario: User can submit a combo to a group assignment before the first deadline
  Scenario: User can submit a combo to a group assignment after the first deadline but before the final
  Scenario: User cannot submit to a group assignment after the final deadline
  Scenario: Different users can submit and re-submit text" to a group assignment
  Scenario: Different users can submit and re-submit a file to a group assignment
  Scenario: Different users can submit and re-submit a link to a group assignment
  Scenario: Different users can submit and re-submit a combo to a group assignment
  Scenario: Different users can submit then withdraw a submitted assignment

    Given the Bingo! game required 1 day of lead time
    Given the Bingo! started "last month" and ends "today"
    Given the Bingo! "has" been activated
    Given the user logs in
    Then user should see 0 open task

  Scenario: User should be able to open and save an unstarted list of candidates
    Given the user logs in
    Then user should see 1 open task
    When the user clicks the link to the candidate list
    Then the user should see the Bingo candidate list
    Then the user will see 7 term field sets
    Then the candidate entries should be empty
    Then the user clicks "Save"
    Then the candidate properties should be empty

  Scenario: User should be able to enter candidates with an assigned course consent
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has" been presented to the user
    Given the user logs in
    Then user should see 1 open task
    Then user should see a consent form listed for the open bingo
    When the user clicks the link to the candidate list
    Then the user should see the Bingo candidate list
    Then the user will see 7 term field sets
    Then the candidate entries should be empty
    Then the user clicks "Save"
    Then the candidate properties should be empty

  Scenario: User should be able to open update and then re-edit a list of candidates
    Given the user logs in
    Then user should see 1 open task
    When the user clicks the link to the candidate list
    Then the user should see the Bingo candidate list
    When the user populates 3 of the "term" entries
     And the user populates 3 of the "definition" entries
    Then the user clicks "Save"
    Then the user will see "success"
    Then retrieve the latest Bingo! game from the db
    Then the candidate list entries should match the list
    When the user populates 7 of the "term" entries
     And the user populates 7 of the "definition" entries
    Then the user clicks "Save"
    Then the user will see "success"
    Then the candidate list entries should match the list
    Then the user logs out
    Then the user logs in
    Then the user will see "100%"
    Then retrieve the latest Bingo! game from the db
    Then the candidate list properties will match the list

  @javascript
  Scenario: User should be able to open update and then re-edit a list of candidates
    Given the user logs in
    Then user should see 1 open task
    When the user clicks the link to the candidate list
    Then the user should see the Bingo candidate list
    When the user populates 7 of the "term" entries
     And the user populates 7 of the "definition" entries
    Then the user clicks "Save"
    Then the user will see "success"
    Then the candidate list entries should match the list
    Then the user logs out
    Then the user logs in
    Then the user will see "100%"
    Then retrieve the latest Bingo! game from the db
    Then the candidate list properties will match the list

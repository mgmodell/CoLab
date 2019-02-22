Feature: Submitting Candidate words for Bingo!
  Students must be able to reach and submit their words for Bingo!

  Background:
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 7
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the Bingo! "has" been activated
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested

  Scenario: User should not be able to closed list of candidates
    Given the Bingo! "has not" been activated
    Given the user logs in
    Then user should see 0 open task

  Scenario: User should not be able to closed list of candidates
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

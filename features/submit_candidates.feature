Feature: Submitting Candidate words for Bingo!
  Students must be able to reach and submit their words for Bingo!

  Background:
    Given there is a course with an assessed project
    Given the course started "two months ago" and ended "two months later"
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has a Bingo! game
    Given the user is the "first" user in the group
    Given the user "has" had demographics requested

  Scenario: User should not be able to closed list of candidates
    Given the Bingo! game required 1 day of lead time
    Given the Bingo! started "last month" and ends "tomorrow"
    Given the user logs in
    Then user should see 0 open task

  Scenario: User should be able to open an unstarted list of candidates

  Scenario: User should be able to open a list of candidates that is in progress
    Given the Bingo! game required 1 day of lead time
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the user logs in
    Then user should see 1 open task

  Scenario: User should be able to save a partial list of candidates

  Scenario: User should be able to save a completed list of candidates

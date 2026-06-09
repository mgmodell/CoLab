Feature: LTI Deep Linking – Connect CoLab Activities to Moodle
  As a Moodle instructor
  I want to create deep links from my Moodle course directly to specific CoLab
  activities (Terms List, Projects, Experiences) so that:
  - Students can reach those activities in one click from Moodle.
  - A gradebook column is automatically created in Moodle for graded activities.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course has a Bingo! game
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the project started "5/10/1976" and ends "11/01/2012", opened "Saturday" and closes "Monday"
    Given the Bingo! started "2/29/1980" and ends "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the user is the instructor for the course
    Given a registered LTI deployment exists for issuer "http://moodle:8080"

  # ──────────────────────────────────────────────────────────────────────────
  # Content-selection page
  # ──────────────────────────────────────────────────────────────────────────

  @javascript
  Scenario: Deep-linking launch shows the CoLab activity-selection page
    When a deep-linking LTI launch arrives from "http://moodle:8080"
    Then the content-selection page is displayed
    And the page lists the CoLab course with its bingo game
    And the page lists the CoLab course with its project

  @javascript
  Scenario: Deep-linking launch lists experiences alongside other activities
    Given the course has an experience
    Given the experience started "2/29/1980" and ends "7/10/2008"
    When a deep-linking LTI launch arrives from "http://moodle:8080"
    Then the content-selection page is displayed
    And the page lists the CoLab course with its experience

  # ──────────────────────────────────────────────────────────────────────────
  # Activity selection – Terms List (Bingo! Game)
  # ──────────────────────────────────────────────────────────────────────────

  @javascript
  Scenario: Selecting a Terms List creates a deep-link response with a gradebook entry
    When a deep-linking LTI launch arrives from "http://moodle:8080"
    Then the content-selection page is displayed
    When the user selects the "bingo game" for deep linking
    Then a deep-linking response JWT is returned to Moodle
    And the deep-link content item is for the bingo game
    And the deep-link content item includes a line item for gradebook tracking

  # ──────────────────────────────────────────────────────────────────────────
  # Activity selection – Project
  # ──────────────────────────────────────────────────────────────────────────

  @javascript
  Scenario: Selecting a Project creates a deep-link response with a gradebook entry
    When a deep-linking LTI launch arrives from "http://moodle:8080"
    Then the content-selection page is displayed
    When the user selects the "project" for deep linking
    Then a deep-linking response JWT is returned to Moodle
    And the deep-link content item is for the project
    And the deep-link content item includes a line item for gradebook tracking

  # ──────────────────────────────────────────────────────────────────────────
  # Activity selection – Experience (no gradebook)
  # ──────────────────────────────────────────────────────────────────────────

  @javascript
  Scenario: Selecting an Experience creates a deep-link response without a gradebook entry
    Given the course has an experience
    Given the experience started "2/29/1980" and ends "7/10/2008"
    When a deep-linking LTI launch arrives from "http://moodle:8080"
    Then the content-selection page is displayed
    When the user selects the "experience" for deep linking
    Then a deep-linking response JWT is returned to Moodle
    And the deep-link content item is for the experience
    And the deep-link content item does not include a line item

Feature: LTI Moodle Platform Connection
  As a CoLab administrator or instructor
  I want to establish an LTI 1.3 connection between the containerised Moodle
  instance and CoLab, and then link individual courses across the two systems,
  so that students can access CoLab activities from within Moodle and so that
  enrolments are kept in sync.

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
    Given the user is an admin

  # ──────────────────────────────────────────────────────────────────────────
  # Dynamic Registration – Moodle discovers CoLab's LTI 1.3 configuration
  # ──────────────────────────────────────────────────────────────────────────

  @javascript
  Scenario: Moodle discovers CoLab's LTI 1.3 configuration via Dynamic Registration
    When the user visits the CoLab LTI Dynamic Registration URL
    Then the LTI tool configuration is returned
    And the LTI tool configuration includes an OIDC login URI
    And the LTI tool configuration includes a launch redirect URI
    And the LTI tool configuration includes a JWKS URI
    And the LTI tool configuration advertises Deep Linking support

  # ──────────────────────────────────────────────────────────────────────────
  # LTI resource-link launch – connects the Moodle course to the CoLab course
  # ──────────────────────────────────────────────────────────────────────────

  @javascript
  Scenario: LTI resource-link launch from Moodle creates a link between the two courses
    Given a registered LTI deployment exists for issuer "http://moodle:8080"
    When a Moodle LTI launch links the Moodle course "Introduction to CoLab" to the CoLab course
    Then the CoLab course has an LTI resource link from "http://moodle:8080"
    And the LTI resource link records the Moodle context title "Introduction to CoLab"

  @javascript
  Scenario: LTI resource-link launch enrolls the launching user in the linked CoLab course
    Given a registered LTI deployment exists for issuer "http://moodle:8080"
    When a Moodle instructor launches CoLab and links it to the CoLab course as "instructor@moodle.local"
    Then the user "instructor@moodle.local" is enrolled in the CoLab course
    And the user "instructor@moodle.local" has the instructor role in the CoLab course

  @javascript
  Scenario: A second LTI launch from the same Moodle course is idempotent
    Given a registered LTI deployment exists for issuer "http://moodle:8080"
    Given the Moodle course "Introduction to CoLab" is already linked to the CoLab course
    When a Moodle instructor launches CoLab and links it to the CoLab course as "instructor@moodle.local"
    Then the CoLab course has exactly 1 LTI resource link from "http://moodle:8080"

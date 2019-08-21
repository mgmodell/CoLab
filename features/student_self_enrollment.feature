Feature: Presenting Consent Forms
  In order to be allowed to use the collected data,
  Students must be able to consent to its usage.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the user is the "last" user in the group
    Given the factor pack is set to "Original"

  Scenario: a student can self-enroll in an open course
  Scenario: a student can re-enroll after being dropped
  Scenario: a student cannot self-enroll in an inactive course
  Scenario: a student cannot self-enroll in an closed course
  Scenario: a student cannot self-enroll in a course that has not opened


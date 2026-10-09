Feature: Instructor student progress
  Instructors should be able to see student progress for open activities.

  Background:
    Given a user has signed up
    And the user "has" had demographics requested
    And there is a course
    And the course has 4 confirmed users
    And the course started "4 months ago" and ends "2 months from now"
    And the user is the instructor for the course

  @javascript
  Scenario: Instructor opens progress for an active experience
    Given the course has an experience
    And the experience started "yesterday" and ends "2 months hence"
    And the experience "has" been activated
    When the user logs in
    Then the instructor sees the experience and its student progress

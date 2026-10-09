Feature: Experience completion timing stats
  Instructors need to see how long students engage with an Experience.

  Background:
    Given there is a course with an experience
    Given the course has 1 confirmed users

  Scenario: Timing stats are calculated for a completed reaction
    Given a reaction started 100 minutes ago with diagnoses after 10, 40 and 50 minutes and reaction after 60 minutes
    Then the reaction timing stats show a total time of 3600 seconds
     And the reaction timing stats show an average diagnosis time of 1000 seconds
     And the reaction timing stats show a diagnosis time standard deviation of 566 seconds
     And the reaction timing stats show a reaction time of 600 seconds

  Scenario: Timing stats for an incomplete reaction
    Given an incomplete reaction with no diagnoses
    Then the reaction timing stats show no times

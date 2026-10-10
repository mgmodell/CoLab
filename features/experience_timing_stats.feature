Feature: Experience completion timing stats
  Instructors need to see how long students engage with an Experience.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
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

  @javascript
  Scenario: Instructor sees the timing stats in the Results tab
    Given the course started "5/10/1976" and ended "tomorrow"
    Given the user is the instructor for the course
    Given a reaction started 100 minutes ago with diagnoses after 10, 40 and 50 minutes and reaction after 60 minutes
    Then the user logs in and accesses the "Courses" admin page
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user switches to the "Results" tab
    Then the results row for the reaction shows these times
      | Total Time | Avg. Diagnosis Time | Diagnosis Time Std. Dev. | Reaction Time |
      | 1:00:00    | 0:16:40             | 0:09:26                  | 0:10:00       |

  @javascript
  Scenario: Instructor sees N/A for an incomplete reaction in the Results tab
    Given the course started "5/10/1976" and ended "tomorrow"
    Given the user is the instructor for the course
    Given an incomplete reaction with no diagnoses
    Then the user logs in and accesses the "Courses" admin page
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user switches to the "Results" tab
    Then the results row for the reaction shows these times
      | Total Time | Avg. Diagnosis Time | Diagnosis Time Std. Dev. | Reaction Time |
      | N/A        | N/A                 | N/A                      | N/A           |

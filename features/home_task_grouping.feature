Feature: Home task grouping
  Students should be able to group HomeShell tasks by type, course, and close-date week.

  Background:
    Given there is a course with an experience
    And the course has 4 confirmed users
    And the users "have" had demographics requested

  @javascript
  Scenario: Selecting and expanding task groups
    Given the experience started "yesterday" and ends "tomorrow"
    And the experience "has" been activated
    And the user is "a random" user
    When the user logs in
    Then the user selects task grouping "Type"
    And the task group header contains "Group Experience"
    When the user collapses the task group "Group Experience"
    Then the experience task is hidden
    When the user expands the task group "Group Experience"
    Then the experience task is visible
    When the user selects task grouping "Course"
    Then the task group header contains the course name
    When the user selects task grouping "Close date week"
    Then the task group header contains the close-date week

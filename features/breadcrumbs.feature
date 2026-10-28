Feature: Application breadcrumbs
  Breadcrumbs should identify icon types and avoid links to nonexistent activity listings.

  Background:
    Given a user has signed up
    And the user "has" had demographics requested
    And there is a course with an assessed project

  @javascript
  Scenario: Listing and activity breadcrumbs have useful tooltips and links
    Given the user is the instructor for the course
    Then the user logs in and accesses the "Courses" admin page
    Then the user opens the course
    Then the course listing and item breadcrumb links are separate
    Then the course activity breadcrumb shows its type icon only

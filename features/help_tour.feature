Feature: Help tour
  Users should be able to click the help button and receive contextual
  driver.js tour guidance for the current page.

  Background:
    Given there is a registered user
    And the user 'is' confirmed

  @javascript
  Scenario: User sees the home page tour
    Then the user logs in
    Then the user clicks the help button
    Then the user should see a tour popover
    And the tour popover title should contain "Welcome to the Application!"
    Then the user closes the tour

  @javascript
  Scenario: User sees the profile page tour
    Then the user logs in
    Then user opens their profile
    Then the user clicks the help button
    Then the user should see a tour popover
    And the tour popover title should contain "Edit your profile"
    Then the user closes the tour

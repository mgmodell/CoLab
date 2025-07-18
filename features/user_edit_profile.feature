Feature: User edit Profile
  A user should be able to modify their profile information

  Background:
    Given there is a registered user

  @javascript
  Scenario: User should be asked to enter profile information on first login
    And the user 'is not' confirmed
    Then the user logs in
    Then the user 'does' see the 'Edit your profile' page
    Then the user sets the 'first name' to 'Jack'
    Then the user sets the 'last name' to 'Black'
    Then close all messages
    Then the user saves the profile
    Then the user 'does not' see the 'Edit your profile' page
    Then user should see 0 open task
    Then user opens their profile
    Then the user sees the 'first name' is 'Jack'
    Then the user sees the 'last name' is 'Black'

  @javascript
  Scenario: User should be asked to enter profile information on first login
    And the user 'is' confirmed
    Then the user logs in
    Then the user 'does not' see the 'Edit your profile' page

  @javascript
  Scenario: User should be able to edit their profile information
    And the user 'is' confirmed
    Then the user logs in
    Then user opens their profile
    Then the user sets the 'first name' to 'Joe'
    Then the user sets the 'last name' to 'Doe'
    Then the user opens the demographics pane
    Then the user sets the 'birth date' to '7/29/1984'
    Then the user sets the 'start school date' to '4/13/1994'
    Then the user saves the profile
    Then the most recent user is the same as the current user
    Then user opens their profile
    Then the user sees the 'first name' is 'Joe'
    Then the user sees the 'last name' is 'Doe'
    Then the user opens the demographics pane
    Then the user sees the 'birth date' is '07/29/1984'
    Then the user sees the 'start school date' is '04/13/1994'


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
    Then the user 'first name' is 'Jack'
    Then the user 'last name' is 'Black'

  @javascript
  Scenario: User should be asked to enter profile information on first login
     And the user 'is' confirmed
    Then the user logs in
    Then the user 'does not' see the 'Edit your profile' page

  @javascript
  Scenario: User should be able to edit their profile information
    Then the user logs in
    Then the user 'does' see the 'Edit your profile' page
    Then the user sets the 'first name' to 'Joe'
    Then the user sets the 'last name' to 'Doe'
    Then the user sets their 'birth date' to '7/29/1984'
    Then the user saves the profile
    Then the user 'does' see the 'Edit your profile' page
    Then the user 'first name' is 'Joe'
    Then the user 'last name' is 'Doe'
    Then the user sees their 'birth date' is '7/29/1984'
    And the user in the database has the 'first name' of 'John'
    And the user in the database has the 'last name' of 'Doe'
    And the user in the database has the 'birth date' '7/29/1984'


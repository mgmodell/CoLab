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

  @javascript
  Scenario: User can generate a password reset email using their primary address
    Given the email queue is empty
      And there are no performed tasks
    And the user 'is' confirmed
    When the user visits the index
    Then the user switches to the "Forgot your password?" tab
    Then the user fills in the password reset form with their "primary" email address
    Then there are no performed tasks
    Then the user clicks "Send me reset password instructions"
    Then 1 emails will be sent
    Then 0 emails will be tracked

  @javascript
  Scenario: User can generate a password reset email using their secondary address
    Given the email queue is empty
      And there are no performed tasks
    Given the user has an additional email address
    And the user 'is' confirmed
    When the user visits the index
    Then the user switches to the "Forgot your password?" tab
    Then the user fills in the password reset form with their "secondary" email address
    Then there are no performed tasks
    Then the user clicks "Send me reset password instructions"
    Then 2 emails will be sent
    Then 0 emails will be tracked

  @javascript
  Scenario: User should be able to access their courses tab
    And the user 'is' confirmed
    Then the user logs in
    Then user opens their profile
     And the user switches to the "My Courses" tab
     And the user sees 'Course list'

  @javascript
  Scenario: User should see their research participation in their profile
    And the user 'is' confirmed
    Then the user logs in
    Then user opens their profile
     And the user switches to the "Research Participation" tab
     And the user sees 'Study title'

  @javascript
  Scenario: User should see all activites they've participated in in their profile
    And the user 'is' confirmed
    Then the user logs in
    Then user opens their profile
     And the user switches to the "History" tab
     And the user sees 'Activity list'
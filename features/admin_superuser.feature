Feature: Administration: user
  Users should not be able to perform any administrative tasks.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the user is an admin

@javascript
  Scenario: Regular users do not see the Admin button 
    Given the user is the instructor for the course
    Given there is a course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
     And the user waits to see "Available Courses"
    Then the user sees 2 course

@javascript
  Scenario: Regular users do not see the Admin button 
    Given there is a course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
     And the user waits to see "Available Courses"
    Then the user sees 2 course

@javascript
  Scenario: Regular users do not see the Admin button 
    Given the course started "4 months ago" and ended "2 months from now"
    Given the course has an assessed project
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
     And the user waits to see "Available Courses"
    Then the user sees 1 course

@javascript
  Scenario: Regular users do not see the Admin button
    Given the course has an experience
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
     And the user waits to see "Available Courses"
    Then the user sees 1 course

@javascript
  Scenario: Regular users do not see the Admin button
    Given the course has a Bingo! game
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
     And the user waits to see "Available Courses"
    Then the user sees 1 course

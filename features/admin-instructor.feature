Feature: Administration: instructor
  Instructors should be able to perform administrative tasks
  on their own courses.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "11/01/2012"

    Given the user is the instructor for the course

  Scenario: Instructors see admin buttons with a project
    Given the course has an assessed project
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Instructors see admin buttons with an experience
    Given the course has an experience
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Regular users do not see the Admin button
    Given the course has a Bingo! game
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Instructor users see admin buttons.
    Given the course has a Bingo! game
    Given there is a course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

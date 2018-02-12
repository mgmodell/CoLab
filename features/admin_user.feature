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

  Scenario: Regular users do not see the Admin button 
    Given there is a course
    Given the user logs in
    Then the user "does not" see an Admin button

  Scenario: Regular users do not see the Admin button 
    Given the course has an assessed project
    Given the user logs in
    Then the user "does not" see an Admin button

  Scenario: Regular users do not see the Admin button
    Given the course has an experience
    Given the user logs in
    Then the user "does not" see an Admin button

  Scenario: Regular users do not see the Admin button
    Given the course has a Bingo! game
    Given the user logs in
    Then the user "does not" see an Admin button

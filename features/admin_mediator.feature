Feature: Mediator Administration
  Test our ability to perform basic administrative
  tasks on Meeting Mediator settings.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has 5 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "4 months hence"
    Given the project started "5/10/1978" and ends "10/29/2012", opened "Saturday" and closes "Monday"
    Given the course started "5/10/1976" and ended "11/01/2012"

  Scenario: Instructor enables mediation
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user edits the course
    Then the user "enables" meeting mediation
    Then the user saves the course
    Then the course has meeeting mediation "enabled" in the db

  Scenario: Instructor enables then disables mediation
    Given the course has meeting mediation enabled
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user edits the course
    Then the user "disables" meeting mediation
    Then the user saves the course
    Then the course has meeeting mediation "disabled" in the db
    Then the course has 0 mediated meetings assigned in the db

  Scenario: Instructor enables mediation, then assigns three meetings
    Given the course has meeting mediation enabled
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user edits the course
    Then the user assignes 3 mediated meetings
    Then the user saves the course
    Then the course has 3 mediated meetings assigned in the db

  Scenario: Instructor enables mediation, then assigns two meetings
    Given the course has meeting mediation enabled
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user edits the course
    Then the user assignes 2 mediated meetings
    Then the user saves the course
    Then the course has 2 mediated meetings assigned in the db

  Scenario: Instructor reviews a completed meeting
    Given the course has meeting mediation enabled
    Given a group completes a mediated meeting
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user sees one mediated meeting
    Then the user opens the mediated meeting
    Then the rest is pending


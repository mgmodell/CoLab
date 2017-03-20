Feature: Project Administration
  Test our ability to perform basic administrative
  tasks on a project.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the user logs in

  Scenario: Regular users do not see the Admin button
    Then the user "does not" see an Admin button

  Scenario: Admin users do see the Admin button
    Given the user is an admin
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Instructor users do see the Admin button
    Given the user is the instructor for the course
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Instructor creates a new project
    Given the user is the instructor for the course
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

  Scenario: Instructor edits an existing project
    Given the user is the instructor for the course
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

  Scenario: Instructor assigns a course's students to groups
    Given the user is the instructor for the course
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

  Scenario: Instructor changes group assignments
    Given the user is the instructor for the course
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

  Scenario: Instructor creates a project then edits it
    Given the user is the instructor for the course
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

Feature: Project Administration
  Test our ability to perform basic administrative
  tasks on a project.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the user timezone is "Seoul"

  Scenario: Regular users do not see the Admin button
    Given the user logs in
    Then the user "does not" see an Admin button

  Scenario: Admin users do see the Admin button
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Instructor users do see the Admin button
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course

  Scenario: Instructor creates a new project
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Add Project"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the "Start" date to "5/10/1976"
    Then the user sets the "End" date to "2/29/1980"
    Then the user sets the "Starting day of the week" to "Monday"
    Then the user sets the "Ending day of the week" to "Tuesday"
    Then the user sets the "Factor pack" to "Simple"
    Then the user sets the "Style" to "Sliders (simple)"
    Then the user sets the "Description" to "this is the coolest"
    Then the user clicks "Create Project"
    Then retrieve the latest project from the db
    Then the project name is "Cool-yo!"
    Then the project "Start" date is "5/10/1976"
    Then the project "End" date is "2/29/1980"
    Then the project "Factor pack" is "Simple"
    Then the project "Style" is "Sliders (simple)"
    Then the project "Description" is "this is the coolest"

  Scenario: Instructor edits an existing project
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Edit" on the existing project
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the "Start" date to "5/10/1976"
    Then the user sets the "End" date to "2/29/1980"
    Then the user sets the "Starting day of the week" to "Monday"
    Then the user sets the "Ending day of the week" to "Tuesday"
    Then the user sets the "Factor pack" to "Simple"
    Then the user sets the "Style" to "Sliders (simple)"
    Then the user sets the "Description" to "this is the coolest"
    Then the user clicks "Create Project"
    Then retrieve the latest project from the db
    Then the project name is "Cool-yo!"
    Then the project "Start" date is "5/10/1976"
    Then the project "End" date is "2/29/1980"
    Then the project "Factor pack" is "Simple"
    Then the project "Style" is "Sliders (simple)"
    Then the project "Description" is "this is the coolest"

  Scenario: Instructor assigns a course's students to groups
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

  Scenario: Instructor changes group assignments
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

  Scenario: Instructor creates a project then edits it
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    #Continue this

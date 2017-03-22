Feature: Project Administration
  Test our ability to perform basic administrative
  tasks on a project.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course started "5/10/1976" and ended "11/01/2012"
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
    Then the user sets the "start" date to "02/29/1980"
    Then the user sets the "end" date to "07/10/2008"
    Then the user selects "Monday" as "Opens every"
    Then the user selects "Tuesday" as "Closes every"
    Then the user selects "Simple" as "Factor pack"
    Then the user selects "Sliders (simple)" as "Style"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user clicks "Create Project"
    Then the user will see "success"
    #Let's check the values stored
    Then retrieve the latest project from the db
    Then the project "Name" is "Cool-yo!"
    Then the project "Description" is "this is the coolest"
    #check the dates
    Then the project "start" date is "02/29/1980"
    Then the project "end" date is "07/10/2008"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

  Scenario: Instructor edits an existing project
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Edit" on the existing project
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the "start" date to "05/10/1976"
    Then the user sets the "end" date to "02/29/1980"
    Then the user selects "Monday" as "Opens every"
    Then the user selects "Tuesday" as "Closes every"
    Then the user selects "Simple" as "Factor pack"
    Then the user selects "Sliders (simple)" as "Style"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user clicks "Update Project"
    Then the user will see "success"
    Then retrieve the latest project from the db
    #Let's check the values stored
    Then retrieve the latest project from the db
    Then the project "Name" is "Cool-yo!"
    Then the project "Description" is "this is the coolest"
    #check the dates
    Then the project "start" date is "5/10/1976"
    Then the project "end" date is "2/29/1980"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

  Scenario: Instructor creates a project then edits it
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Add Project"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the "start" date to "02/29/1980"
    Then the user sets the "end" date to "07/10/2008"
    Then the user selects "Monday" as "Opens every"
    Then the user selects "Tuesday" as "Closes every"
    Then the user selects "Simple" as "Factor pack"
    Then the user selects "Sliders (simple)" as "Style"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user clicks "Create Project"
    Then the user will see "success"
    #Let's check the values stored
    Then retrieve the latest project from the db
    Then the project "Name" is "Cool-yo!"
    Then the project "Description" is "this is the coolest"
    #check the dates
    Then the project "start" date is "02/29/1980"
    Then the project "end" date is "07/10/2008"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

    Then the user clicks "Edit Project" on the existing project
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the "start" date to "05/10/1976"
    Then the user sets the "end" date to "02/29/1980"
    Then the user selects "Monday" as "Opens every"
    Then the user selects "Tuesday" as "Closes every"
    Then the user selects "Simple" as "Factor pack"
    Then the user selects "Sliders (simple)" as "Style"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user clicks "Update Project"
    Then the user will see "success"
    Then retrieve the latest project from the db
    #Let's check the values stored
    Then retrieve the latest project from the db
    Then the project "Name" is "Cool-yo!"
    Then the project "Description" is "this is the coolest"
    #check the dates
    Then the project "start" date is "5/10/1976"
    Then the project "end" date is "2/29/1980"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

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


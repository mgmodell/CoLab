Feature: Bingo Administration
  Test our ability to perform basic administrative
  tasks on a Bingo! game.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course has a Bingo! game
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "11/01/2012"

  Scenario: Instructor creates a new Bingo! game
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Bingo Game"
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor prep" field to "2"
    Then the user sets the "Terms per individual" field to "15"
    Then the user sets the "Percent fewer terms if working in a group" field to "30"
    Then the user sets the project to the course's project
    Then the user sets the "start" date to "02/29/1980"
    Then the user sets the "end" date to "07/10/2008"
    Then the user sets the "Description" field to "this is the coolest"
    Then show me the page
    Then the user clicks "Create Bingo game"
    Then the user will see "success"
    #Let's check the values stored
    Then retrieve the latest Bingo! game from the db
    Then the bingo "topic" is "Privacy"
    Then the bingo "description" is "this is the coolest"
    Then the bingo "individual_count" is "15"
    Then the bingo "group_discount" is "30"
    Then the bingo "lead_time" is "2"
    Then the bingo project is the course's project
    #check the dates
    Then the bingo "start" date is "02/29/1980"
    Then the bingo "end" date is "07/10/2008"

  Scenario: Instructor creates a new Bingo! game but leaves the dates untouched
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Bingo Game"
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor prep" field to "2"
    Then the user sets the "Terms per individual" field to "15"
    Then the user sets the "Percent fewer terms if working in a group" field to "30"
    Then the user sets the project to the course's project
    Then the user sets the "Description" field to "this is the coolest"
    Then show me the page
    Then the user clicks "Create Bingo game"
    Then the user will see "success"
    #Let's check the values stored
    Then retrieve the latest project from the db
    Then the bingo "topic" is "Privacy"
    Then the project "Description" is "this is the coolest"
    #check the dates
    Then the project "start" date is "05/10/1976"
    Then the project "end" date is "11/01/2012"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

  Scenario: Instructor edits an existing Bingo!
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
    Then the user clicks "Update Bingo game"
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


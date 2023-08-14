Feature: Bingo Administration
  Test our ability to perform basic administrative
  tasks on a Bingo! game.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course has a Bingo! game
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the project started "5/10/1976" and ends "11/01/2012", opened "Saturday" and closes "Monday"
    Given the Bingo! started "2/29/1980" and ends "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"

  @javascript
  Scenario: Instructor creates a new Bingo! game
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Terms List"
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor review" field to "2"
    Then the user sets the "Entries per student" field to "15"
    Then the user checks "Make groups available?"
    Then the user sets the "Discount for collaboration" field to "30"
    Then the user sets the project to the course's project
    Then the user sets the bingo "start" date to "02/29/1980"
    Then the user sets the bingo "end" date to "07/10/2008"
    Then the user sets the rich "Description" field to "this is the coolest"
    Then the user clicks "Create Bingo Game"
    Then the user will see "success"
    Then close all messages
    #Let's check the values stored
    Then retrieve the latest Bingo! game from the db
    Then the bingo "topic" is "Privacy"
    Then the bingo "description" is "<p>this is the coolest</p>"
    Then the bingo "individual_count" is "15"
    Then the bingo "group_discount" is "30"
    Then the bingo "lead_time" is "2"
    Then the bingo project is the course's project
    #check the dates
    Then the bingo "start" date is "02/29/1980"
    Then the bingo "end" date is "07/10/2008"

  @javascript
  Scenario: Instructor creates a new Bingo! game but leaves the dates untouched
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Terms List"
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor review" field to "2"
    Then the user sets the "Entries per student" field to "15"
    Then the user checks "Make groups available?"
    Then the user sets the "Discount for collaboration" field to "30"
    Then the user sets the project to the course's project
    Then the user sets the rich "Description" field to "this is the coolest"
    Then the user clicks "Create Bingo Game"
    Then the user will see "success"
    Then close all messages
    #Let's check the values stored
    Then retrieve the latest Bingo! game from the db
    Then the bingo "topic" is "Privacy"
    Then the bingo "Description" is "<p>this is the coolest</p>"
    #check the dates
    Then the bingo "start" date is "05/10/1976"
    Then the bingo "end" date is "11/01/2012"
    #check the selects

  @javascript
  Scenario: Instructor edits an existing Bingo!
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks on the existing bingo game
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor review" field to "2"
    Then the user sets the "Entries per student" field to "15"
    Then the user clicks by label "Make groups available?"
    Then the user sets the "Discount for collaboration" field to "30"
    Then the user sets the project to the course's project
    Then the user sets the rich "Description" field to "this is the coolest"
    Then the user clicks "Update Bingo Game"
    Then the user waits while seeing "Saving game"
    Then the user will see "success"
    #Let's check the values stored
    Then retrieve the latest Bingo! game from the db
    Then the bingo "Topic" is "Privacy"
    Then the bingo "Description" is "<p>this is the coolest</p>"
    #check the dates
    Then the bingo "start" date is "2/29/1980"
    Then the bingo "end" date is "7/10/2008"


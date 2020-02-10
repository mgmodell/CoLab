Feature: Bingo Administration
  Test our ability to perform basic administrative
  tasks on a Bingo! game.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course has a Bingo! game
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the Bingo! started "2/29/1980" and ends "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"

  @javascript
  Scenario: Instructor creates a new Bingo! game without a project
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user clicks "New Bingo! Game"
     And the "Make groups available?" label is disabled
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor prep" field to "2"
    Then the user sets the "Entries per student" field to "15"
    Then the user sets the bingo "start" date to "02/29/1980"
    Then the user sets the bingo "end" date to "07/10/2008"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user clicks "Create Bingo game"
    Then the user will see "success"
    #Let's check the values stored
    Then retrieve the latest Bingo! game from the db
    Then the bingo "topic" is "Privacy"
    Then the bingo "description" is "this is the coolest"
    Then the bingo "individual_count" is "15"
    Then the bingo "lead_time" is "2"
    Then the bingo project is empty
    #check the dates
    Then the bingo "start" date is "02/29/1980"
    Then the bingo "end" date is "07/10/2008"

  @javascript
  Scenario: Instructor edits an existing Bingo!
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Show" on the existing bingo game
     And the "Make groups available?" label is disabled
    Then the user sets the "Topic" field to "Privacy"
    Then the user sets the "Days for instructor review" field to "2"
    Then the user sets the "Entries per student" field to "15"
    Then the user sets the rich "Description" field to "this is the coolest"
    Then the user clicks "Update Bingo Game"
    Then the user waits while seeing "Saving game"
    Then the user will see "successfully"
    #Let's check the values stored
    Then retrieve the latest Bingo! game from the db
    Then the bingo "Topic" is "Privacy"
    Then the bingo "Description" is "<p>this is the coolest</p>"
    Then the bingo project is empty
    #check the dates
    Then the bingo "start" date is "2/29/1980"
    Then the bingo "end" date is "7/10/2008"


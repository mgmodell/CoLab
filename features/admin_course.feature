Feature: Course Administration
  Test our ability to perform basic administrative
  tasks on a course.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the project started '5/12/1976' and ends '10/01/2012'

  Scenario: Admin creates a new course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
     And the user clicks "New Course"
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone is "Nairobi"
    Then the user clicks "Create Course"
     And the user will see "success"
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is "099"
     And the course "Description" field is "I love to eat peas and carrots all day long"
     And the course start date is "tomorrow" and the end date to "next month"
     And the course "timezone" is "Nairobi"

  Scenario: Admin cannot creates an incomplete new course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
     And the user clicks "New Course"
     #no name
     And the user sets the "Name" field to ""
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone is "Nairobi"
    Then the user clicks "Create Course"
     And the user will see "Error"
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "" and the end date to "next month"
    Then the user clicks "Create Course"
     And the user will see "Error"
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to ""
     And the timezone is "Nairobi"
    Then the user clicks "Create Course"
     And the user will see "Error"
     #no number or description
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to ""
     And the user sets the "Description" field to ""
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone is "Nairobi"
    Then the user clicks "Create Course"
     And the user will see "success"
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is ""
     And the course "Description" field is ""
     And the course start date is "tomorrow" and the end date to "next month"
     And the course "timezone" is "Nairobi"

  Scenario: Instructor cannot create a new course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user does not see a "New Course" button

  Scenario: Admin edits an existing course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone is "Nairobi"
    Then the user clicks "Create Course"
     And the user will see "success"
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is "099"
     And the course "Description" field is "I love to eat peas and carrots all day long"
     And the course start date is "tomorrow" and the end date to "next month"
     And the course "timezone" is "Nairobi"

  Scenario: Admin duplicates an existing course
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the course 'name' is 'to dup'
    Given the course 'number' is 'd6'
    Given the course 'description' is 'ohla!'
    Given the course has an Experience
    Given the Experience started "6/20/1976" and ends "8/20/1976"
    Given the Experience "name" is "cup"
    Given the course has a Bingo! game
    Given the Bingo! started "5/20/1976" and ends "7/20/1976"
    Given the Bingo! "Topic" field is "Private"
    Given the Bingo! "Description" is "this is neat"
    Given the Bingo! "Terms count" is 20
    Given the Bingo! prep days is 2
    Given the Bingo! project is the course's project
    Given the Bingo! percent discount is 30
    Given the Bingo! is active
    Given the user is the instructor for the course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user clicks the "Make another"
     And set the new course start date to "5/20/1976"
    Then the user sees 2 course
    #Let's check what we've got
    Then retrieve the latest course from the db
     And the course "Name" field is "Copy of to dup"
     And the course "Number" field is "d6"
     And the course "Description" field is "ohla!"
     And the course start date is "5/20/1976" and the end date to "11/11/2012"
     And the course "timezone" is "Mexico City"
     And the course has 1 instructor user
     And the course instructor is the user
    #check the experience
    Then retrieve the 1 course 'experience'
    Then the Experience 'name' is 'cup'
    Then the new 'Experience' dates are "6/30/1976" and "8/30/1976"
     And the new 'Experience' is 'not' active
    #check the project
    Then retrieve the 1 course 'project'
    Then the new project metadata is the same as the old
    Then the new 'project' started '5/22/1976' and ends '10/11/2012'
    Then the new project has 0 groups
     And the new 'project' is 'not' active
    #check the bingo
    Then retrieve the 1 course 'bingo'
    Then the new bingo metadata is the same as the old
    Then the new 'bingo' started '5/30/1976' and ends '7/30/2012'
     And the new 'bingo' is 'not' active

Feature: Assignment administration
  Test our ability to perform basic administrative
  tasks on an incrementally submittable assignment.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there are 4 "published" rubrics starting with 'Ruby'
    Given there are 4 "unpublished" rubrics starting with "Never gonna' give you up"
    Given there is a course with an assessed project
    Given the user is the instructor for the course
    Given the course has 8 confirmed users
    Given the course has an assignment named "Sack Troy" with an "unpublished" rubric named "Trojan War Diorama"
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the project started "5/10/1976" and ends "11/01/2012", opened "Saturday" and closes "Monday"
    Given the assignment opening is "2/29/1980" and close is "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course

  @javascript
  Scenario: Instructor creates a new assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Assignment"
    Then the user sets the "Name" field to "Term Paper"
    Then the user sets the rich "Description" field to "Compare and contrast Muppet Babies with Animaniacs. The result should be a 20 page paer."
    Then the user sets the assignment "opening" to "7/29/1984"
    Then the user sets the assignment "close" to "2/10/1985"
    Then the user selects the 'Ruby 2' version 1 rubric
    Then the user clicks "Create Assignment"
    Then close all messages
    #Csheck what was saved
    Then retrieve the "latest" assignment from the db
     And the assignment "Name" field is "Term Paper"
     And the assignment "Description" field is "Compare and contrast Muppet Babies with Animaniacs. The result should be a 20 page paer."
     And the assignment "opening" field is "7/29/1984"
     And the assignment "close" field is "2/10/1985"
    Then the assignment rubric is 'Ruby 2' version 1
     And the assignment "is not" active
     And the assignment "is not" group capable

  @javascript
  Scenario: Instructor creates a group-capable assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Assignment"
    Then the user sets the "Name" field to "Term Paper"
    Then the user sets the rich "Description" field to "Compare and contrast Muppet Babies with Animaniacs. The result should be a 20 page paer."
    Then the user sets the assignment "opening" to "7/29/1984"
    Then the user sets the assignment "close" to "2/10/1985"
    Then the user selects the 'Ruby 2' version 1 rubric
    Then the user checks "Make groups available?"
    Then the user sets the assignment project to the course project
    Then the user clicks "Create Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "latest" assignment from the db
     And the assignment "Name" field is "Term Paper"
     And the assignment "Description" field is "Compare and contrast Muppet Babies with Animaniacs. The result should be a 20 page paer."
     And the assignment "opening" field is "7/29/1984"
     And the assignment "close" field is "2/10/1985"
     And the assignment "is not" active
     And the assignment "is" group capable
     And the assignment project is the course project


  @javascript
  Scenario: Instructor activates an assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
     And the user selects the "Sack Troy" activity
    Then the user checks "Is Active?"
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "latest" assignment from the db
     And the assignment "is" active

  @javascript
  Scenario: Instructor makes an assignment group-capable
    Then the user opens the course
    Then the user switches to the "Activities" tab
     And the user selects the "Sack Troy" activity
    Then the user checks "Make groups available?"
    Then the user sets the assignment project to the course project
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "latest" assignment from the db
     And the assignment "is" group capable
     And the assignment project is the course project
     And the assignment "is not" active

  @javascript
  Scenario: Instructor assigns their own published rubric to an assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
    # This may need rework
    Given the user has one 'published' rubric named "Pie in the Sky"
     And the user selects the "Sack Troy" activity
    Then the user selects the 'Pie in the Sky' version 1 rubric
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "Sack Troy" assignment from the db
     And the assignment rubric is "Pie in the Sky"

  @javascript
  Scenario: Instructor assigns a new rubric to a new assignment
    Then the user creates a new "New Assignment"
    Then the user sets the "Name" field to "Term Paper"
    Then the user sets the rich "Description" field to "Compare and contrast Muppet Babies with Animaniacs. The result should be a 20 page paer."
    Then the user sets the assignment "opening" to "7/29/1984"
    Then the user sets the assignment "close" to "2/10/1985"
    Then the user clicks "Add New Rubric"
     And the user sets the "Rubric Name" field to "Sky in the Pie"
    Then the user clicks "Create Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "latest" rubric
     And the rubric "Name" is "Sky in the Pie"
    Then retrieve the "latest" assignment from the db
     And the assignment "Name" field is "Term Paper"
     And the assignment rubric is "Sky in the Pie"

  @javascript
  Scenario: Instructor assigns a new rubric to an existing assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
     And the user selects the "Sack Troy" activity
    Then the user clicks "Add New Rubric"
     And the user sets the "Rubric Name" field to "Sky in the Pie"
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "latest" rubric
     And the rubric "Name" is "Sky in the Pie"
    Then retrieve the "Sack Troy" assignment from the db
     And the assignment rubric is "Sky in the Pie"

  @javascript
  Scenario: Instructor assigns a published rubric to an assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
     And the user selects the "Sack Troy" activity
    Then the user selects the 'Ruby 2' version 1 rubric
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "Sack Troy" assignment from the db
     And the assignment rubric is "Ruby 2"

  @javascript
  Scenario: Instructor sets the deadlines for an assignment
    Then the user opens the course
    Then the user switches to the "Activities" tab
     And the user selects the "Sack Troy" activity
    Then the user sets the assignment "close" to "6/9/2000"
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "Sack Troy" assignment from the db
     And the assignment "close" field is "6/9/2000"

  @javascript
  Scenario: Instructor sets an assignment to be group-capable
    Then the user opens the course
    Then the user switches to the "Activities" tab
     And the user selects the "Sack Troy" activity
    Then the user checks "Make groups available?"
    Then the user sets the assignment project to the course project
    Then the user clicks "Save Assignment"
    Then close all messages
    #Check what was saved
    Then retrieve the "Sack Troy" assignment from the db
     And the assignment project is the course project
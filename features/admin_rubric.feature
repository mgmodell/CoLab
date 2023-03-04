Feature: Rubric administration
  Test our ability to perform basic administrative
  tasks on an incrementally submittable assignment.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there are 4 "published" rubrics starting with 'Ruby '
    Given there are 4 "unpublished" rubrics starting with "Never gonna' give you up "
    Given there is a course with an assessed project
    Given the course has 8 confirmed users
    Given the user is the most recently created user
    Given the user is the instructor for the course
    Given the course has an assignment named "Sack Troy" with an "unpublished" rubric named "Trojan War Diorama"
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the project started "5/10/1976" and ends "11/01/2012", opened "Saturday" and closes "Monday"
    Given the assignment opening is "2/29/1980" and close is "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Rubrics' menu item

  @javascript
  Scenario: Instructor creates a rubric
    Then the user sees 5 rubrics
    Then the user clicks the "new-activity" button
     And the user sets the "Name" field to "Elderly Tech. Talk"
     And the user sets the "Description" field to "Students prepare and deliver a presentation explaining a technology topic to elderly members of their community."
     And the user sets criteria 1 "Description" to "History"
     And the user sets criteria 1 level 3 to "Introduces 3 important milestones and 3 important people in the evolution of the technology"
     And the user sets criteria 1 level 2 to "Introduces fewer than 3 important milestones or fewer than 3 important people in the evolution of the technology"
     And the user sets criteria 1 level 1 to "Introduces fewer than 3 total important milestones and important people in the evolution of the technology"
     And the user sees the criteria 1 weight is 1
    Then the user adds a new criteria
    Then the user will see an empty criteria 2
     And the user sets criteria 2 "Description" to "Functionality"
     And the user sets criteria 2 level 2 to "Introduces fewer than 3 common features with understandable explanations of how they work"
     And the user sees the criteria 2 weight is 1
     And the user sets the criteria 2 weight to 3
     And the user sets criteria 2 level 1 to "Introduces fewer than 3 common features and explains how each one works"
     And the user sets criteria 2 level 3 to "Introduces 3 common features and explains how each one works"
    Then the user clicks the "save-rubric" button
    Then close all messages
    #Check what was saved
    Then retrieve the "latest" rubric from the db
     And the user is the owner of the rubric
     And the rubric version is 1
     And the rubric "Name" field is "Elderly Tech. Talk"
     And the rubric "Description" field is "Students prepare and deliver a presentation explaining a technology topic to elderly members of their community."
     And the rubric criteria 1 "Description" is "History"
     And the rubric criteria 1 level 3 is "Introduces 3 important milestones and 3 important people in the evolution of the technology"
     And the rubric criteria 1 level 2 is "Introduces fewer than 3 important milestones or fewer than 3 important people in the evolution of the technology"
     And the rubric criteria 1 level 1 is "Introduces fewer than 3 total important milestones and important people in the evolution of the technology"
     And the rubric criteria 1 weight is 1
     And the rubric criteria 2 "Description" is "Functionality"
     And the rubric criteria 2 level 2 is "Introduces fewer than 3 common features with understandable explanations of how they work"
     And the rubric criteria 2 level 1 is "Introduces fewer than 3 common features and explains how each one works"
     And the rubric criteria 2 level 3 is "Introduces 3 common features and explains how each one works"
     And the rubric criteria 2 weight is 3

  @javascript
  Scenario: Instructor searches for a published rubric
    Then the user searches for "Ruby 1"
    Then the user sees 1 rubrics

  @javascript
  Scenario: Instructor searches for their own unpublished rubric
    Then the user searches for "Trojan"
    Then the user sees 1 rubrics

  @javascript
  Scenario: Instructor searches for a colleague's unpublished rubric
    Then the user searches for "Never gonna' give you up 1"
    Then the user sees 0 rubrics

  @javascript
  Scenario: Admin searches for a colleague's unpublished rubric
     And the user is an admin
    Then the user searches for "Never gonna' give you up 1"
    Then the user sees 1 rubrics

  @javascript
  Scenario: Instructor publishes a rubric
    Then the user searches for "Trojan"
    Then the user edits the "Trojan" rubric
     And close all messages
     And the user clicks 'Save and publish'
    Then the user will see "success"
    #Check what was saved
    Then retrieve the "Trojan War Diorama" rubric from the db
     And the rubric "Name" field is "Trojan War Diorama"
     And the rubric "is" published
    

  @javascript
  Scenario: Instructor unpublishes their rubric
   Given the "Trojan War Diorama" rubric is published
    Then the user searches for "Trojan"
    Then the user edits the "Trojan" rubric
     And the user clicks "Save and Unpublish"
    Then the user will see "success"
    #Check what was saved
    Then retrieve the "Trojan War Diorama" rubric from the db
     And the rubric "Name" field is "Trojan War Diorama"
     And the rubric "is not" published

  @javascript
  Scenario: Admin unpublishes a rubric
   Given the user is an admin
    Then the user searches for "Ruby 1"
    Then the user edits the "Ruby 1" rubric
     And the user clicks "Save and Unpublish"
    Then the user will see "success"
    #Check what was saved
    Then retrieve the "Ruby 1" rubric from the db
     And the rubric "Name" field is "Ruby 1"
     And the rubric "is not" published

  @javascript
  Scenario: Instructor copies their own rubric
    Then the user searches for "Trojan"
    Then the user copies the "Trojan War Diorama" rubric
    Then the user will see "success"
    #Check what was saved
    Then retrieve the "latest" rubric from the db
     And the rubric "Name" is "Trojan War Diorama"
     And the rubric "Version" is 2
     And the rubric owner "is" the user
     And the rubric parent is "Trojan War Diorama" version 1
     And the rubric "is not" published


  @javascript
  Scenario: Instructor copies a public rubric
    Then the user searches for "Ruby 1"
    Then the user copies the "Ruby 1" rubric
    Then the user will see "success"
    #Check what was saved
    Then retrieve the "latest" rubric from the db
     And the rubric "Name" is "Ruby 1"
     And the rubric "Version" is 1
     And the rubric owner "is" the user
     And the rubric parent is "Ruby 1" version 1
     And the rubric "is not" published

  @javascript
  Scenario: Instructor adds a row to their unpublished rubric
     And the "Trojan War Diorama" rubric has 5 criteria
    Then the user searches for "Trojan"
    Then the user edits the "Trojan" rubric
    Then the user adds a new criteria
    Then the user will see an empty criteria 6
     And the user sets criteria 6 "Description" to "New Criteria"
     And the user sets criteria 6 level 1 to "level 1"
     And the user sets criteria 6 level 2 to "level 2"
     And the user sets criteria 6 level 3 to "level 3"
     And the user adds a level to criteria 6
     And the user sets criteria 6 level 4 to "level 4"
     And the user sets the criteria 6 weight to 30
    Then the user clicks "Update Rubric"
    Then close all messages
    #Check what was saved
    Then retrieve the "Trojan War Diorama" rubric from the db
     And the user is the owner of the rubric
     And the rubric version is 1
     And the rubric criteria 6 "Description" is "New Criteria"
     And the rubric criteria 6 level 3 is "level 3"
     And the rubric criteria 6 level 2 is "level 3"
     And the rubric criteria 6 level 1 is "level 3"
     And the rubric criteria 6 level 4 is "level 4"
     And the rubric criteria 6 weight is 30


  @javascript
  Scenario: Instructor removes a row from their unpublished rubric
     And the "Trojan War Diorama" rubric has 5 criteria
    Then retrieve the "Trojan War Diorama" rubric from the db
    Then remember the data for criteria 3
    Then the user searches for "Trojan"
    Then the user edits the "Trojan" rubric
     And the user sees that criteria 3 matches the remembered criteria
     And the user deletes criteria 2
    Then the user clicks "Update Rubric"
    Then close all messages
    #Check what was saved
    Then retrieve the "Trojan War Diorama" rubric from the db
     And criteria 2 matches the remembered criteria

  @javascript
  Scenario: Instructor modifies their unpublished rubric
     And the "Trojan War Diorama" rubric has 5 criteria
    Then retrieve the "Trojan War Diorama" rubric from the db
    Then remember the data for criteria 3
    Then the user searches for "Trojan"
    Then the user edits the "Trojan" rubric
    Then the user moves criteria 3 up 1
     And the user sets criteria 5 level 3 to "super-duper"
     And the user adds a level to criteria 4
     And the user sets criteria 4 level 4 to "super duper level 4"
     And the user adds a level to criteria 4
     And the user sets criteria 4 level 5 to "super duper level 5"
    Then the user clicks "Update Rubric"
    Then close all messages
    #Check what was saved
    Then retrieve the "Trojan War Diorama" rubric from the db
     And criteria 2 matches the remembered criteria
     And the rubric criteria 5 level 3 is "super-duper"
     And the rubric criteria 4 level 4 is "super duper level 4"
     And the rubric criteria 4 level 5 is "super duper level 5"

  @javascript
  Scenario: Admin deletes an unpublished rubric
   Given the user is an admin
    Then the user searches for "Ruby 1"
    Then the user deletes the rubric

  @javascript
  Scenario: Admin cannot delete a rubric that is in published
   Given the user is an admin
    Then the user searches for "Ruby 1"
     And the user can not 'delete' the rubric

  @javascript
  Scenario: Instructor cannot modify a published rubric
    Then the user searches for "Trojan"
     And the user can not 'delete' the rubric
     And the user can not 'edit' the rubric

  # For later implementation
  # Scenario: Instructor adds a counter element to a rubric
  # Scenario: Instructor removes a counter element from a rubric


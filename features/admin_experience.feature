Feature: Experience Administration
  Test our ability to perform basic administrative
  tasks on an Experience

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an experience
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "tomorrow"
    Given the experience started "2/29/1980" and ends "7/10/2008"
    Given the user is the instructor for the course
    Given the user logs in

@javascript
  Scenario: Instructor creates a new Experience
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Group Experience"
    Then the user sets the "Name" field to "Jimmy Hendrix"
    Then the user sets the "Days for instructor prep" field to "5"
    Then close all messages
    Then the user clicks "Create Experience"
     And the user waits to see "success"
     Then close all messages
    #Let's check the values stored
    Then retrieve the latest Experience from the db
     And the experience "name" is "Jimmy Hendrix"
     And the experience "lead_time" is 5
     And the experience start date is "5/10/1976" and the end date is "tomorrow"

@javascript
  Scenario: Instructor creates a new Experience and accepts lead time default
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Group Experience"
    Then the user sets the "Name" field to "Jimmy Hendrix"
    Then close all messages
    Then the user clicks "Create Experience"
     And the user waits to see "success"
     Then close all messages
    #Let's check the values stored
    Then retrieve the latest Experience from the db
     And the experience "name" is "Jimmy Hendrix"
     And the experience "lead_time" is 3
     And the experience start date is "5/10/1976" and the end date is "tomorrow"

@javascript
  Scenario: Instructor creates a new Experience
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user creates a new "New Group Experience"
    Then the user sets the "Name" field to "Jimmy Hendrix"
    Then the user sets the "experience" start date to "2/29/1980" and the end date to "7/10/2008"
    Then close all messages
    Then the user clicks "Create Experience"
     And the user waits to see "success"
     Then close all messages
    #Let's check the values stored
    Then retrieve the latest Experience from the db
     And the experience "name" is "Jimmy Hendrix"
    Then the experience start date is "2/29/1980" and the end date is "7/10/2008"

@javascript
  Scenario: Instructor edits an existing Experience
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user sets the "Name" field to "Bob Marley"
    Then the user sets the "experience" start date to "2/29/1980" and the end date to "7/10/2008"
    Then close all messages
    Then the user clicks "Save Experience"
     And the user waits to see "success"
     Then close all messages
    #Let's check the values stored
    Then retrieve the latest Experience from the db
     And the experience "name" is "Bob Marley"
     And the experience "lead_time" is 3
    Then the experience start date is "2/29/1980" and the end date is "7/10/2008"

@javascript
  Scenario: Instructor edits an existing Experience with lead time
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user sets the "Name" field to "Bob Marley"
    Then the user sets the "experience" start date to "2/29/1980" and the end date to "7/10/2008"
    Then the user sets the "Days for instructor prep" field to "5"
    Then close all messages
    Then the user clicks "Save Experience"
     And the user waits to see "success"
     Then close all messages
    #Let's check the values stored
    Then retrieve the latest Experience from the db
     And the experience "name" is "Bob Marley"
     And the experience "lead_time" is 5
    Then the experience start date is "2/29/1980" and the end date is "7/10/2008"


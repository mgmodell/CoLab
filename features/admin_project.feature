Feature: Project Administration
  Test our ability to perform basic administrative
  tasks on a project.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1976" and ended "4 months hence"
    Given the project started "5/10/1978" and ends "10/29/2012", opened "Saturday" and closes "Monday"
    Given the course started "5/10/1976" and ended "11/01/2012"

  Scenario: Instructor creates a new project
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Project"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the project "start" date to "02/29/1980"
    Then the user sets the project "end" date to "07/10/2008"
    Then the user selects "Monday" as "Opens every"
    Then the user selects "Tuesday" as "Closes every"
    Then the user selects "Simple" as "Factor pack"
    Then the user selects "Sliders (simple)" as "Style"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user "enables" chat
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
    Then the project Chat is "enabled"

  Scenario: Instructor creates a new project
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Project"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the project "start" date to "02/29/1980"
    Then the user sets the project "end" date to "07/10/2008"
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
    Then the project Chat is "disabled"

  Scenario: Instructor creates a new project but leaves the dates untouched
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Project"
    Then the user sets the "Name" field to "Cool-yo!"
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
    Then the project "start" date is "05/10/1976"
    Then the project "end" date is "11/01/2012"
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
    Then the user sets the project "start" date to "05/10/1976"
    Then the user sets the project "end" date to "02/29/1980"
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

  Scenario: Instructor creates a project and doesn't set the dates then edits it
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Project"
    Then the user sets the "Name" field to "Cool-yo!"
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
    Then the project "start" date is "05/10/1976"
    Then the project "end" date is "11/01/2012"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

    Then the user clicks "Edit Project Details"
    Then the user sets the "Name" field to "Cool-yo!"
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
    Then the project "end" date is "11/01/2012"
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
    Then the user clicks "New Project"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the project "start" date to "02/29/1980"
    Then the user sets the project "end" date to "07/10/2008"
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

    Then the user clicks "Edit Project Details"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the project "start" date to "05/10/1976"
    Then the user sets the project "end" date to "02/29/1980"
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

  Scenario: Instructor creates a project then edits it, but doesn't edit the dates
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "New Project"
    Then the user sets the "Name" field to "Cool-yo!"
    Then the user sets the project "start" date to "02/29/1980"
    Then the user sets the project "end" date to "07/10/2008"
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

    Then the user clicks "Edit Project Details"
    Then the user sets the "Name" field to "Cool beans"
    Then the user selects "Monday" as "Opens every"
    Then the user selects "Tuesday" as "Closes every"
    Then the user selects "Simple" as "Factor pack"
    Then the user selects "Sliders (simple)" as "Style"
    Then the user sets the "Description" field to "this is the coolest"
    Then the user clicks "Update Project"
    Then the user will see "success"
    Then retrieve the latest project from the db
    #Let's check the values stored
    Then the project "Name" is "Cool beans"
    Then the project "Description" is "this is the coolest"
    #check the dates
    Then the project "start" date is "02/29/1980"
    Then the project "end" date is "07/10/2008"
    #check the selects
    Then the project Factor pack is "Simple"
    Then the project Style is "Sliders (simple)"

  Scenario: Instructor assigns a course's students to groups
    Given the course started "5/10/1976" and ended "4 months hence"
    Given the project started "last month" and ends "next month", opened "Saturday" and closes "Monday"
    Given the course started "last month" and ended "next month"
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course

    Then the user clicks "Show" on the existing project
    Then the user sets the "New group name" field to "my group"
    Then the user clicks "Add!"
    Then the user will see "success"
    Then the user sets the "New group name" field to "your group"
    Then the user clicks "Add!"
    #Edit the groups
    Then the user clicks "Edit Project Details"
    Then the user sets the project "start" date to "yesterday"
    Then the user sets the project "end" date to "tomorrow"

    Then set user 1 to group "my group"
    Then the user clicks "Update Project"
    Then the user will see "success"
    Then retrieve the latest project from the db
    Then the project "start" date is "yesterday"
    Then the project "end" date is "tomorrow"
    Then retrieve the latest project from the db
    Then group "my group" has 1 user
    Then group "my group" has 1 revision

  Scenario: No 2 groups in 1 project can have the same name
    Given the course started "5/10/1976" and ended "4 months hence"
    Given the project started "last month" and ends "next month", opened "Saturday" and closes "Monday"
    Given the course started "last month" and ended "next month"
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course

    Then the user clicks "Show" on the existing project
    Then the user sets the "New group name" field to "my group"
    Then the user clicks "Add!"
    Then the user will see "success"
    Then the user sets the "New group name" field to "my group"
    Then the user clicks "Add!"
    Then the user will see "Error"
    Then the user will see "Group names must be unique"

  Scenario: No 2 groups in 1 class can have the same name
    Given the course started "5/10/1976" and ended "4 months hence"
    Given the project started "last month" and ends "next month", opened "Saturday" and closes "Monday"
    Given the course started "last month" and ended "next month"
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Show" on the existing project
    Then the user sets the "New group name" field to "my group"
    Then the user clicks "Add!"
    Then the user will see "success"

    Then the user returns home
     And the course has a project named "awesome"
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Show" on project "awesome"
    Then the user sets the "New group name" field to "my group"
    Then the user clicks "Add!"
    Then the user will see "Error"
    Then the user will see "Group names must be unique"

  Scenario: Existing Sat-Mon proj=> Fri-Sat on Sat => tomorrow no emails, no access
    Given the email queue is empty
    Given the project has a group with 4 confirmed users
    Given the user is the "a random" user in the group
    Given the user "has" had demographics requested
    Given the user timezone is "Mexico City"
    Given today is "10/13/1979"
    Given the factor pack is set to "Simple"
    Given the project has been activated
     When the system emails stragglers
     When the system emails stragglers
     When the system emails stragglers
     Then 4 emails will be sent
     Then 4 emails will be tracked
     When the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
    Given the user logs out

    # Change the project
    Given the email queue is empty
     When the project started "5/10/1978" and ends "10/29/2012", opened "Friday" and closes "Saturday"
    Given the project has been activated
    Given today is "10/14/1979"
     When the system emails stragglers
     When the system emails stragglers
     When the system emails stragglers
     Then 0 emails will be sent
     Then 4 emails will be tracked
     When the user logs in
     Then the user should see a successful login message
     Then user should see 0 open task

  Scenario: Existing Sat-Mon proj=> Fri-Sat on Sun=> no emails, no access
    Given the course timezone is "UTC"
    Given the user timezone is "UTC"
    Given the email queue is empty
    Given the project has a group with 4 confirmed users
    Given the user is the "a random" user in the group
    Given the user "has" had demographics requested
    Given the user timezone is "UTC"
    Given today is "10/14/1979"
    Given the factor pack is set to "Simple"
    Given the project has been activated
     When the system emails stragglers
     When the system emails stragglers
     When the system emails stragglers
     Then 4 emails will be sent
     Then 4 emails will be tracked
     When the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
    Given the user logs out

    # Change the project
    Given the email queue is empty
     When the project started "5/10/1978" and ends "10/29/2012", opened "Friday" and closes "Saturday"
    Given the project has been activated
     When the system emails stragglers
     When the system emails stragglers
     When the system emails stragglers
     Then 0 emails will be sent
     Then 4 emails will be tracked
     When the user logs in
     Then the user should see a successful login message
     Then user should see 0 open task

  Scenario: End date=> 10/10/1979 on 11/10/1979=> no emails, no access
    # Change the project
    Given today is "11/10/1979"
    Given the email queue is empty
    Given the project has a group with 4 confirmed users
    Given the user is the "a random" user in the group
    Given the user "has" had demographics requested
    Given the user timezone is "Mexico City"
     When the project started "5/10/1978" and ends "10/10/1979", opened "Friday" and closes "Saturday"
    Given the project has been activated
     When the system emails stragglers
     When the system emails stragglers
     When the system emails stragglers
     Then 0 emails will be sent
     Then 0 emails will be tracked
     When the user logs in
     Then the user should see a successful login message
     Then user should see 0 open task

  Scenario: A deactivated project incurs no emails and is not listed
    Given the email queue is empty
    Given the project has a group with 4 confirmed users
    Given the user is the "a random" user in the group
    Given the user "has" had demographics requested
    Given the user timezone is "Mexico City"
    Given today is "10/14/1979"
     When the project has been deactivated
     When the system emails stragglers
     When the system emails stragglers
     When the system emails stragglers
     Then 0 emails will be sent
     Then 0 emails will be tracked
     When the user logs in
     Then the user should see a successful login message
     Then user should see 0 open task

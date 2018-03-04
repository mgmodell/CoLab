Feature: School Administration
  Test our ability to perform basic administrative
  tasks on a school.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"

  Scenario: Admin creates a new school
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
     And the user clicks "Schools"
     And the user clicks "New School"
     And the user sets the "Name" field to "hard knocks"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
    Then the user clicks "Create School"
     And the user will see "successfully"
    Then retrieve the latest school from the db
     And the school "Name" field is "hard knocks"
     And the school "Description" field is "I love to eat peas and carrots all day long"

  Scenario: Admin cannot creates an incomplete new school
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
     And the user clicks "Schools"
     And the user clicks "New School"
     #no name
     And the user sets the "Name" field to ""
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
    Then the user clicks "Create School"
     And the user will see "Please review the problems below"
     #Now we complete it
     And the user sets the "Name" field to "life"
    Then the user clicks "Create School"
     #We should have success now
     And the user will see "successfully"
    Then retrieve the latest school from the db
     And the school "Name" field is "life"
     And the school "Description" field is "I love to eat peas and carrots all day long"

  Scenario: Instructor cannot create a new school
    Given there is a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user does not see a "Schools" link

  Scenario: Admin edits an existing school
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
     And the user clicks "Schools"
    Then the user sees 2 school
    Then the user opens the school
    Then the user clicks "Edit school details"
     And the user sets the "Name" field to "Off"
     And the user sets the "Description" field to "blue is the best"
    Then the user clicks "Update School"
    Then retrieve the latest school from the db
     And the school "Name" field is "Off"
     And the school "Description" field is "blue is the best"


Feature: Admins can find and review users and update their roles.
  Searching can be done by family name, given name or email address.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
      And the user is the instructor for the course
    Given the course has an experience
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users

    Given there is a course with an assessed project
    Given the course has a Bingo! game
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as a group"
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as a group"

    Given there is a course
    Given the course has 11 confirmed users
    # User is instructor only for the first course

    Given there is a course
    Given the course is in "Test School" school
    Given the project has a group with 4 confirmed users
    Given the course has a Bingo! game
    Given the users "finish" prep "as a group"
    Given the course has an assignment
      And the init assignment 'does' accept 'links'
    Given the assignment "is" initialised as group-capable
    Given the assignment opening is "one month ago" and close is "one month from now"
    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment

  @javascript
  Scenario: An instructor can find students in their school and content is limited
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 28 students visible
    Then the user "does not" see a merge button
    Then the user searches for a user by "complete" "family name" from "their course"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed as "enrolled"
     And the user "does not" see a "role edit" button
     And the user "does not" see a "delete" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "given name" from "their school"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed as "enrolled"
     And the user "does not" see a "role edit" button
     And the user "does not" see a "delete" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "email" from "their course"
     And the user "is not" found
    Then the user searches for a user by "complete" "email" from "their course"
     And the user "is" found
    Then the user searches for a user by "complete" "email" from "another school"
     And the user "is not" found

  @javascript
  Scenario: A researcher can find all users school anonymized with no roles
    Then there is a user who is a researcher
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 36 students visible
    Then the user "does not" see a merge button
    Then the user searches for a user by "complete" "anonymized family name" from "their school"
     And the user "is" found
    Then the user views the user
     And the user sees anonymized data with no roles
    Then the user sees 1 course listed as "enrolled"
     And the user "does not" see a "role edit" button
     And the user "does not" see a "delete" button
    Then the user closes the user view
    Then the user searches for a user by "complete" "anonymized email" from "another school"
     And the user "is not" found
    Then the user sees 36 students visible

  @javascript
  Scenario: An admin can view any user by family name and school
    Then the user an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 36 students visible
    Then the user searches for a user by "complete" "family name" from "their course"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed as "enrolled"
     And the user "does" see a "role edit" button
     And the user "does" see a "delete" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "given name" from "their school"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed as "enrolled"
     And the user "does" see a "role edit" button
     And the user "does" see a "delete" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "email" from "their course"
     And the user "is not" found
    Then the user searches for a user by "complete" "email" from "their course"
     And the user "is" found
    Then the user searches for a user by "complete" "email" from "another school"
     And the user "is" found
    Then the user views the user
     And the user "does" see a "role edit" button
     And the user "does" see a "delete" button
    Then the user searches for a user by "complete" "email" from "self"
     And the user "is not" found

  @javascript
  Scenario: An admin can delete and restore any user by email
    Then the user an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 36 students visible
    Then the user searches for a user by "complete" "email" from "any school"
    Then the user clicks the delete button on the user
    Then the user sees 35 students visible
    Then the user searches for a user by "complete" "email" from "any school"
    Then the user clicks the delete button on the user
    Then the user sees 34 students visible
    Then the user clcks the "Restore user" button
     And the user enters the email address for deleted user 1
     And the user clicks the "Restore" button
    Then the user sees 35 students visible
    Then the user searches for a user by "complete" "email" from "user 1"
     And the user "is" found
    Then the user searches for a user by "complete" "email" from "user 2"
     And the user "is not" found

  @javascript
  Scenario: An admin can set any user as researcher by email
    Then the user an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user searches for a user by "complete" "email" from "student"
     And the user "is" found
     And the user clicks the "Make researcher" button
    Then the user is a "researcher"
    Then the user searches for a user by "complete" "email" from "researcher"
     And the user "is" found
     And the user clicks the "Remove researcher" button
    Then the user is a "student"

  @javascript
  Scenario: An admin can set any user as researcher by email
    Then the user an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user searches for a user by "complete" "email" from "student"
     And the user "is" found
     And the user clicks the "Make admin" button
    Then the user is a "researcher"
    Then the user searches for a user by "complete" "email" from "admin"
     And the user "is" found
     And the user clicks the "Remove admin" button
    Then the user is a "student"

  @javascript
  Scenario: An admin can merge 2 users useing email addresses
   Given select user 1 from "the users" "course"
   Given select user 2 from "Test School" "school"
    Then the user an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user "does not" see a merge button
    Then switch to user 1
    Then the user successfully completes an experience
    Then the user logs in and submits an installment
    Then the user clicks the "Merge two users" button
    Then the user enters the email address for user 1 and user 2
    Then the user clicks the "Merge" button
    Then the user sees a success message
    Then the user searches for user 1 by email
     And the user "is not" found
    Then the user searches for user 2 by email
     And the user "is" found
    Then the user views the user
    Then the user sees 2 course listed as "enrolled"
     And the user sees 1 "experience"
     And the user sees 2 "bingo"

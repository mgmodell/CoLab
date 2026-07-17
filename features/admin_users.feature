Feature: Admins can find and review users and update their roles.
  Searching can be done by family name, given name or email address.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"
      And the user is the instructor for the course
    Given the course has an experience
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    # 1 course with 8 users

    Given there is a course with an assessed project
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the course has a Bingo! game
    Given the course has an experience
    Given the Bingo! game individual count is 6
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! is group-enabled with the project and a 50 percent group discount
    Given the Bingo! "has" been activated
    Given the project has a group with 2 confirmed users
    Given the users "finish" prep "as a group"
    Given the project has a group with 2 confirmed users
    Given the users "incomplete" prep "solo"
    # 1 course with 4 users

    Given there is a course
    Given the course has an experience
    Given the course has 11 confirmed users
    # User is instructor only for the first course
    # 1 course with 11 users

    Given there is a course with an assessed project
    Given the course is in "Test School" school
    Given the project started "two months ago" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 2 confirmed users
    Given the project has been activated
      And the course participants are in the same school as the course
    Given the course has a Bingo! game
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! "has" been activated
    Given the users "finish" prep "solo"
    Given the course has an assignment
      And the init assignment 'does' accept 'links'
    Given the course has an experience
    Given the assignment "is" initialised as group-capable
    Given the assignment opening is "one month ago" and close is "one month from now"
    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    # 1 course with 2 users

  @javascript
  Scenario: An instructor can find students in their school and content is limited
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 24 students visible
     And the user "does not" see an active "Merge users" button
    Then the user searches for a user by "complete" "family name" from "their course"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed
     And the user "does not" see an active "Grant Researcher" button
     And the user "does not" see an active "Grant Admin" button
     And the user "does not" see an active "Grant Instructor" button
     And the user "does not" see an active "Deactivate" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "given name" from "their school"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed
     And the user "does not" see an active "role edit" button
     And the user "does not" see an active "Deactivate" button
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
    Then the user sees 26 students visible
     And the user "does not" see an active "Merge users" button
    Then the user searches for a user by "complete" "anonymized family name" from "their school"
     And the user "is" found
    Then the user views the user
     And the user sees anonymized data with no roles
    Then the user sees 1 course listed
     And the user "does not" see an active "Grant Researcher" button
     And the user "does not" see an active "Grant Admin" button
     And the user "does not" see an active "Grant Instructor" button
     And the user "does not" see an active "Deactivate" button
    Then the user closes the user view
    Then the user searches for a user by "complete" "email" from "another school"
     And the user "is not" found

  @javascript
  Scenario: An admin can view any user by family name and school
    Then the user is an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 26 students visible
    Then the user searches for a user by "complete" "family name" from "their course"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed
     And the user "does" see an active "Grant Researcher" button
     And the user "does" see an active "Grant Admin" button
     And the user "does" see an active "Grant Instructor" button
     And the user "does" see an active "Deactivate" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "given name" from "their school"
     And the user "is" found
    Then the user views the user
    Then the user sees 1 course listed
     And the user "does" see an active "Grant Researcher" button
     And the user "does" see an active "Grant Admin" button
     And the user "does" see an active "Grant Instructor" button
     And the user "does" see an active "Deactivate" button
    Then the user closes the user view
    Then the user searches for a user by "partial" "email" from "their course"
     And the user "is not" found
    Then the user searches for a user by "complete" "email" from "their course"
     And the user "is" found
    Then the user searches for a user by "complete" "email" from "another school"
     And the user "is" found
    Then the user views the user
     And the user "does" see an active "Grant Researcher" button
     And the user "does" see an active "Grant Admin" button
     And the user "does" see an active "Grant Instructor" button
     And the user "does" see an active "Deactivate" button
    Then the user closes the user view
    Then the user searches for a user by "complete" "email" from "self"
     And the user "is not" found

  @javascript
  Scenario: An admin can delete and restore any user by email
    Then the user is an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user sees 26 students visible
    Then there are 0 deleted users
    Then the user searches for a user by "complete" "email" from "any school"
    Then the user clicks "Deactivate"
    Then the user sees 25 students visible
    Then there are 1 deleted users
    Then the user searches for a user by "complete" "email" from "any school"
    Then the user clicks "Deactivate"
    Then the user sees 24 students visible
    Then there are 2 deleted users
    Then the user clicks "Search"
    Then the user clicks "Reactivate"
     And the user searches for deleted user
    Then there are 1 deleted users
     And the user clicks "Reactivate"
    Then the user sees 26 students visible
    Then there are 0 deleted users
    Then the user searches for a user by "complete" "email" from "previous search"
     And the user "is" found

  @javascript
  Scenario: An admin can set any user as researcher by email
    Then the user is an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user searches for a user by "complete" "email" from "student"
     And the user "is" found
     And the user clicks "Grant Researcher"
     And the user will see "Researcher granted"
    Then the found user "is" a "researcher"
    Then the user searches for a user by "complete" "email" from "researcher"
     And the user "is" found
     And the user clicks "Revoke Researcher"
     And the user will see "Researcher revoked"
    Then the found user "is not" a "researcher"

  @javascript
  Scenario: An admin can set any user as admin by email
    Then the user is an admin
    Then the user logs in and accesses the "Users" admin page
    Then the user searches for a user by "complete" "email" from "student"
     And the user "is" found
     And the user clicks "Grant Admin"
     And the user will see "Admin granted"
    Then the found user "is" a "admin"
    Then the user searches for a user by "complete" "email" from "admin"
     And the user "is" found
     And the user clicks "Revoke Admin"
     And the user will see "Admin revoked"
    Then the found user "is not" a "admin"

  @javascript
  Scenario: An admin can merge 2 users using email addresses
    Then the user is an admin
    Then select 2 users with "no" shared courses
    Then the user logs in and accesses the "Users" admin page
     And the user "does" see an active "Merge users" button
     And the user logs out
    Then switch to user 1
    Then activate user projects
    Then the user logs in and submits an installment
     And the current experience is from the user
     Then the user navigates home
    Then the user successfully completes an experience
    Then the user reverts
     And the user logs out
    Then the user logs in and accesses the "Users" admin page
     And the user "does" see an active "Merge users" button
     And the selected users stats are saved
    Then the user clicks "Merge users"
    Then the user enters the email address for user 1 and user 2
    Then the user clicks "Merge now"
    Then the user sees a success message
    Then the user searches for user 2 by email
     And the user "is not" found
    Then the user searches for user 1 by email
     And the user "is" found
    Then the user views the user
     And the merged user shows the combined stats
     And user 2 "is not" viable

  @javascript
  Scenario: An admin cannot merge 2 users with shared activities
    Then the user is an admin
    Then select 2 users with "some" shared courses
    Then the user logs in and accesses the "Users" admin page
     And the user "does" see an active "Merge users" button
     And the user logs out
    Then switch to user 1
    Then activate user projects
    Then the user logs in and submits an installment
     And the current experience is from the user
     Then the user navigates home
    Then the user successfully completes an experience
    Then the user reverts
     And the user logs out
    Then the user logs in and accesses the "Users" admin page
     And the user "does" see an active "Merge users" button
    Then the user clicks "Merge users"
    Then the user enters the email address for user 1 and user 2
    Then the user clicks "Merge now"
    Then the user sees "Error merging users"
    Then the user sees "merge not possible"

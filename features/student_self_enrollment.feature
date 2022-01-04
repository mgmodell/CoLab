Feature: Presenting Consent Forms
  In order to be allowed to use the collected data,
  Students must be able to consent to its usage.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the factor pack is set to "Original"
    Given the course has 8 confirmed users
     Then the course has 12 "enrolled student" users

@javascript
  Scenario: An instructor cannot enroll in their own course
    Given the user is the instructor for the course
    Given the user logs in
     Then the user opens the self-registration link for the course
     Then the user sees "you cannot enroll in your own course"
     Then the course has 12 "enrolled student" users
     Then the course has 0 "requesting student" users

@javascript
  Scenario: a student can re-enroll after being dropped
    Given the user is "a random" user
    Given the user is dropped from the course
     Then the user opens the self-registration link for the course
     Then the user submits credentials
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 1 "requesting student" users
     Then the course has 11 "enrolled student" users

@javascript
  Scenario: A course-declined CoLab user self-registers for the course
    Given the user is "a random" user
    Given the user has "declined" the course
     Then the user opens the self-registration link for the course
     Then the user submits credentials
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 1 "requesting student" users
     Then the course has 11 "enrolled student" users

@javascript
  Scenario: A course-invited CoLab user self-registers for the course
    Given a user has signed up
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"
    Given the user has "been invited to" the course
     Then the user opens the self-registration link for the course
     Then the user submits credentials
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 13 "enrolled student" users

@javascript
  Scenario: A new CoLab user self-registers for the course
     Then the user opens the self-registration link for the course
     Then the new user registers
     #Manual signup requires email confirmation, so they will have to
     #start again after registration and confirmation.

@javascript
  Scenario: A logged in course non-enrolled CoLab user self-registers for the course
    Given a user has signed up
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"
      And the user logs in
     Then the user opens the self-registration link for the course
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 1 "requesting student" users

@javascript
  Scenario: A logged in course-enrolled CoLab user self-registers for the course
    Given the user is "a random" user
    Given the user "has" had demographics requested
    Given the user logs in
     Then the user opens the self-registration link for the course
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 12 "enrolled student" users

@javascript
  Scenario: A course-dropped CoLab user self-registers for the course
    Given the user is "a random" user
    Given the user "has" had demographics requested
    Given the user is dropped from the course
     Then the user opens the self-registration link for the course
     Then the user submits credentials
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 1 "requesting student" users
     Then the course has 11 "enrolled student" users

@javascript
  Scenario: A course-declined CoLab user self-registers for the course
    Given the user is "a random" user
    Given the user "has" had demographics requested
    Given the user has "declined" the course
     Then the user opens the self-registration link for the course
     Then the user submits credentials
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 1 "requesting student" users
     Then the course has 11 "enrolled student" users

@javascript
  Scenario: A course-invited CoLab user self-registers for the course
    Given a user has signed up
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"
    Given the user has "been invited to" the course
     Then the course has 1 "invited student" users
     Then the user opens the self-registration link for the course
     Then the user submits credentials
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 13 "enrolled student" users

@javascript
  Scenario: A logged in course non-enrolled CoLab user self-registers for the course
    Given a user has signed up
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"
    Given the user logs in
     Then the user opens the self-registration link for the course
     Then the user sees "Enrollment confirmation"
     Then the user clicks "Enroll me!"
     Then the course has 1 "requesting student" users

@javascript
  Scenario: a student cannot self-enroll in an closed course
    Given the project started "6/10/1970" and ends "two months ago"
    Given the course started "5/10/1970" and ended "last month"
    Given the user is "a random" user
    Given the user logs in
     Then the user opens the self-registration link for the course
     Then the user sees "not currently available"
     Then the user will see no enabled "Enroll me!" button
     Then the course has 12 "enrolled student" users


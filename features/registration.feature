Feature: User registration
  In order to be able to use the collected data,
  Students must be presented an informed consent form
  and be asked to provide demographic data.

  Background:
    Given a user has signed up
    Given the email queue is empty

  @javascript
  Scenario: Registered user provides consent and demographics.
    Given reset time clock to now
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
    Given the user "has not" had demographics requested
    When the user logs in
    Then the user will see a consent request
    When the user "does" provide consent
    Then the user will see a request for demographics
    When the user "does" fill in demographics data
    When the user visits the index
    Then the user will see the task listing page

  @javascript
  Scenario: Registered user does not provide consent
    Given reset time clock to now
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the user is the "last" user in the group
    Given the user "has not" had demographics requested
    When the user logs in
    Then the user will see a consent request
    When the user "does not" provide consent
    Then the user will see a request for demographics
    When the user "does" fill in demographics data
    When the user visits the index
    Then the user will see the task listing page

  Scenario: 2 new instructors are added to a course
    Given 2 users
    Given a course
    Then the users are added to the course as instructors by email address
    Then the course has 2 "Instructor" users
    Then 0 emails will have been sent
    Then the users are added to the course as instructors by email address
    Then the course has 2 "Instructor" users
    Then 0 emails will have been sent

  Scenario: 5 new users are added to a course
    Given 5 users
    Given a course
    Then the users are added to the course by email address
    Then the course has 5 "Invited Student" users
    Then 0 emails will have been sent

  Scenario: 4 existing users are added to a course
    Given 4 users
    Given the users are confirmed
    Given a course
    Then the users are added to the course by email address
    Then the course has 4 "Invited Student" users

  Scenario: 4 existing users and 2 new users are added to a course
    Given 4 users
    Given the users are confirmed
    Given a course
    Then the users are added to the course by email address
    Given 2 users
    Then the users are added to the course by email address
    Then the course has 6 "Invited Student" users
    Then 0 emails will have been sent

  Scenario: 2 students are added to a course twice
    Given 2 users
    Given a course
    Then the users are added to the course by email address
    Then the users are added to the course by email address
    Then the course has 2 "Invited Student" users
    Then 0 emails will have been sent

@javascript
  Scenario: A student accepts enrollment in a course
    Given 5 users
    Given the users are confirmed
    Given there is a course with an experience
    Given the experience started "last month" and ends "two months hence"
    Given the experience "has" been activated
    Then the users are added to the course by email address
    Then the course has 5 "Invited Student" users
    Then the user is "a random" user
    Given the user "has" had demographics requested
    Then the course has 5 "Invited Student" users
    Then the user logs in
    Then the user sees 1 invitation
    Then the user does not see a task listing
    Then the user "accepts" enrollment in the course
    Then user should see 1 open task
    Then the course has 4 "Invited Student" users
    Then the course has 1 "Enrolled Student" users

@javascript
  Scenario: A student declines enrollment in a course
    Given 5 users
    Given the users are confirmed
    Given there is a course with an experience
    Given the experience "has" been activated
    Then the users are added to the course by email address
    Then the course has 5 "Invited Student" users
    Then the user is "a random" user
    Given the user "has" had demographics requested
    Then the course has 5 "Invited Student" users
    Then the user logs in
    Then the user sees 1 invitation
    Then the user does not see a task listing
    Then the user "declines" enrollment in the course
    Then user should see 0 open task
    Then the course has 4 "Invited Student" users
    Then the course has 1 "Declined Student" users

@javascript
  Scenario: A student is invited to 2 courses
    Given 5 users
    Given the users are confirmed
    Given there is a course with an experience
    Given the experience "has" been activated
    Then the users are added to the course by email address
    Then the course has 5 "Invited Student" users
    Given there is a course with an experience
    Given the experience "has" been activated
    Then the users are added to the course by email address
    Then the course has 5 "Invited Student" users
    Then the user is "a random" user
    Given the user "has" had demographics requested
    Then the course has 5 "Invited Student" users
    Then the user logs in
    Then the user sees 2 invitation
    Then the user does not see a task listing

Feature: Instructor can evaluate a submitted leveled assignment
  Instructors must be able to provide feedback (and grades) on submitted
  assignments where the rubric is just a grid.

  Background:
    Given a user has signed up
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the users "have" had demographics requested
    #active and group-capable
    Given the course has an assignment
      And the init assignment 'does' accept 'links'
    Given the assignment "is" initialised as group-capable
    Given the assignment opening is "one month ago" and close is "one month from now"
    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment

    Given 1 user has submitted to the assignment

    Given a user has signed up
      And the user is the instructor for the course
    Given the user is an "instructor" user in the course
    Given the user "has" had demographics requested

  @javascript
  Scenario: Instructor grades the submitted assignment mixed
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'mixed' and 'all' feedback
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor revises a previous evaluation
    Given the user logs in
   Given 2 user has submitted to the assignment
   Given submission 2 'is' graded
    Then the user opens the assignment task
    Then the user selects submission 2
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades 3 consecutive submissions
    Given the user logs in
   Given 5 user has submitted to the assignment
    Then the user opens the assignment task
    # Grade number two
    Then the user selects submission 2
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered
    # Grade number one
    Then the user hides all but the 'Submissions' tab
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered
    # Grade number three
    Then the user hides all but the 'Submissions' tab
    Then the user selects submission 3
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'proficient' and 'all' feedback
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades the latest submission (skipping outdated)
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then the user sets score to 98
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades assignment novice and overrides score
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then the user sets score to 98
    Then close all messages
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered
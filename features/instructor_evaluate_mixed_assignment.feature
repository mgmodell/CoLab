Feature: Instructor can evaluate a submitted leveled assignment
  Instructors must be able to provide feedback (and grades) on submitted
  assignments where the rubric is just a grid.

  Background:
    Given a user has signed up
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "three months ago" and ended "two months from now"
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    #active and open - no group
    Given the course has an assignment
    #default: text only
    Given the assignment "is not" initialised as group-capable
      And the init assignment 'does' accept 'links'
      And the assignment opening is "one month ago" and close is "one month from now"
      And the assignment "is" initialized active
    Given a user has signed up
      And the user is the instructor for the course

    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    Given the user is an "instructor" user in the course
    Given the user "has" had demographics requested
    Given 1 user has submitted to the assignment

  @javascript
  Scenario: Instructor doesn't see a withdrawn task
   Given the submission has been withdrawn
   Given the user logs in
    Then the user sees 'You do not currently have any tasks due'

  @javascript
  Scenario: Instructor grades the submitted assignment proficient
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Assignment submission' tab
     And the contents match the assignment contents
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'proficient' and 'no' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades the submitted assignment competent
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'competent' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades the submitted assignment novice
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'some' feedback
    Then the user saves the critique
    Then the user sees 'Errors'
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades the submitted assignment mixed
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'mixed' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades the submitted assignment random numbers
    Given the user logs in
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
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
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades 3 consecutive submissions by different students
    Given the user logs in
   Given 5 user has submitted to the assignment
    Then the user opens the assignment task
    # Grade number two
    Then the user selects submission 2
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered
    # Grade number one
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered
    # Grade number three
    Then the user selects submission 3
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'proficient' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades the latest submission (skipping outdated)
    Given the user logs in
     And the assignment already has 4 submission from the user
    Then the user opens the assignment task
    Then the user selects the 'latest' submission
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  @javascript
  Scenario: Instructor grades assignment novice and overrides score
    Given the user logs in
    Then the user opens the assignment task
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then the user sets score to 98
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  Scenario: Members view current grade and instructor feedback
  Scenario: Members view assignment submission history


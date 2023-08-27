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
    Given a user has signed up
      And the user is the instructor for the course
    Given the assignment opening is "one month ago" and close is "one month from now"

    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    Given the assignment "is" initialized active
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested
    Given 1 user has submitted to the assignment

  Scenario: Instructor grades the submitted assignment proficient
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

  Scenario: Instructor grades the submitted assignment competent
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'competent' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  Scenario: Instructor grades the submitted assignment novice
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

  Scenario: Instructor grades the submitted assignment mixed
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'mixed' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  Scenario: Instructor grades the submitted assignment random numbers
    Then the user opens the assignment task
    Then the user selects submission 1
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  Scenario: Instructor revises a previous evaluation
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

  Scenario: Instructor grades 3 consecutive submissions by different students
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

  Scenario: Instructor grades the latest submission (skipping outdated)
     And the assignment already has 4 submission from the user
    Then the user opens the assignment task
    Then the user selects the 'latest' submission
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'numbers' and 'all' feedback
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  Scenario: Instructor grades assignment novice and overrids score
    Then the user hides all but the 'Overall feedback' tab
    Then the user enters overall feedback
    Then the user responds to all criteria with 'novice' and 'all' feedback
    Then the user sets score to 98
    Then the user saves the critique
    Then the user sees 'Successfully saved'
     And the db critique matches the data entered

  Scenario: Members view current grade and instructor feedback
  Scenario: Members view assignment submission history


Feature: (Re)Submitting individual assignments
  Students must be able to (re)submit individual assignments

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
    Given a user has signed up
      And the user is the instructor for the course
    Given the assignment opening is "one month ago" and close is "one month from now"

    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    Given the assignment "is" initialized active
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested

  # Availability
  @javascript
  Scenario: User should be able to see an open and active assignment
    Given the assignment "is" initialized active
    Given the user logs in
    Then user should see 1 open task

  @javascript
  Scenario: User should not be able to see an open inactive assignment
    Given the assignment "is not" initialized active
    Given the user logs in
    Then user should see 0 open task

  @javascript
  Scenario: User should be able to see a past active assignment for a still open course
    Given the course is shifted 2 'months' into the 'past'
    Given the assignment "is" initialized active
    Given the user logs in
    Then user should see 1 open task

  @javascript
  Scenario: Past assignments from closed courses are only visible in the profile
    Given the course is shifted 2 'years' into the 'past'
    Given the assignment "is" initialized active
    Given the user logs in
    Then user should see 0 open task
    Then user opens their profile
    Then user sees the assignment in the history
    Then the user opens the assignment history item
     And the shown rubric matches the assignment rubric

  @javascript
  Scenario: User should be able to see an upcoming active assignment that isn't yet open
    Given the course is shifted 2 'months' into the 'future'
    Given the assignment "is" initialized active
    Given the user logs in
    Then user should see 1 open task

  @javascript
  Scenario: User should not be able to see an upcoming active assignment if the course isn't yet open
    Given the course is shifted 4 'months' into the 'future'
    Given the assignment "is" initialized active
    Given the user logs in
    Then user should see 0 open task

  # Rubric viewing
  @javascript
  Scenario: User can see a current assginment's rubric
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
  #   Then the user opens the 'Grading' submissions tab
      And the shown rubric matches the assignment rubric

  @javascript
  Scenario: User can see an upcoming assginment's rubric
    Given the course is shifted 2 'months' into the 'future'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the 'Submissions' tab 'is' enabled
  #   Then the user opens the 'Grading' submissions tab
      And the shown rubric matches the assignment rubric

  @javascript
  Scenario: User can not submit text to an assignment that is closed
    Given the course is shifted 2 'months' into the 'future'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the 'Submissions' tab 'is not' enabled

  @javascript
  Scenario: User does not see an assignment that is inactive
    Given the course is shifted 2 'months' into the 'future'
    Given the assignment "is not" initialized active
    Given the user logs in
     Then the user does not see the assignment task

  # Submit assignments
  @javascript
  Scenario: User can open and submit text to an assignment
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'text' submission
     Then the user clicks 'Save Draft for Further Editing'
     Then the assignment has 1 'draft' submission
      And the 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user
     Then the user clicks 'Submit for Grading'
     Then the assignment has 1 'submitted' submission

  @javascript
  Scenario: User can open and submit a file to an assignment
      And the init assignment 'does not' accept 'text'
      And the init assignment 'does' accept 'files'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'file' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 1 'active' submission
      And the 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user

  @javascript
  Scenario: User can open and submit a link to an assignment
      And the init assignment 'does not' accept 'text'
      And the init assignment 'does' accept 'links'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'link' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 1 'active' submission
      And the 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user

  @javascript
  Scenario: User can open and submit files to an assignment
      And the init assignment 'does not' accept 'text'
      And the init assignment 'does' accept 'files'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'file' submission
     Then the user enters a 'file' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 1 'active' submission
      And the 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user

  @javascript
  Scenario: User can open and submit a combo to an assignment
      And the init assignment 'does' accept 'links'
      And the init assignment 'does' accept 'files'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'text' submission
     Then the user enters a 'link' submission
     Then the user enters a 'file' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 1 'active' submission
      And the 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user

  # Deadline enforcement
  @javascript
  Scenario: User can submit a combo to an assignment before the first deadline
      And the init assignment 'does' accept 'links'
      And the init assignment 'does' accept 'files'
    Given the assignment "is" initialized active
      And the assignment already has 1 submission from the user
      And today is "tomorrow"
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'text' submission
     Then the user enters a 'link' submission
     Then the user enters a 'file' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 2 'active' submission
      And the latest 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user
    
  @javascript
  Scenario: User can submit a combo to an assignment after the first deadline but before the final
      And the init assignment 'does' accept 'links'
      And the init assignment 'does' accept 'files'
    Given the assignment "is" initialized active
      And the assignment already has 1 submission from the user
      And today is between the first assignment deadline and close
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'combo' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 2 'active' submission
      And the latest 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user

  @javascript
  Scenario: User cannot submit to an assignment after the final deadline
      And the init assignment 'does' accept 'links'
      And the assignment already has 1 submission from the user
      And today is after the final deadline
    Given the user logs in
     Then the user opens the assignment task
     Then the 'Submissions' tab 'is not' enabled

  @javascript
  Scenario: User can submit and re-submit to combo assignment
      And the init assignment 'does' accept 'links'
      And the init assignment 'does' accept 'files'
    Given the assignment "is" initialized active
      And the assignment already has 1 submission from the user
      And today is "tomorrow"
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'combo' submission
     Then the user clicks 'Submit Assignment'
     Then the assignment has 2 'active' submission
      And the latest 'latest' db submission data is accurate
      And the submission has no group
      And the submission is attached to the user

  @javascript
  Scenario: User can withdraw a submitted assignment
      And the assignment already has 4 submission from the user
      And today is after the final deadline
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user withdraws submission 3
     Then the assignment has 1 'withdrawn' submission
     Then the assignment has 3 'active' submission

  @javascript
  Scenario: User cannot withdraw a graded assignment
      And the assignment already has 4 submission from the user
      And assignment 2 'is' graded
      And today is after the final deadline
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user 'can' withdraws submission 1
     Then the user 'can' withdraws submission 3
     Then the user 'cannot' withdraws submission 2

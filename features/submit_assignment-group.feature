Feature: (Re)Submitting individual assignments
  Students must be able to (re)submit individual assignments

  Background:
    Given a user has signed up
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has an assignment
    Given the assignment "is" initialised as group-capable
    Given the assignment opening is "one month ago" and close is "one month from now"
    Given there exists a rubric published by another user
    Given the existing rubric is attached to this assignment
    Given the assignment "is" initialized active
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested

  @javascript
  Scenario: User should not be able to see an inactive assignment
    Given the assignment "is not" initialized active
    Given the user logs in
    Then user should see 0 open task
    Then the user logs out
    Then the user is the "random" user in the group
    Then the user "has" had demographics requested
    Then the user logs in
    Then user should see 0 open task

  @javascript
  Scenario: User should not be able to see a closed group assignment
    Given the course is shifted 2 'years' into the 'past'
    Given the user logs in
    Then user should see 0 open task
    Then the user logs out
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested
    Then the user logs in
    Then user should see 0 open task

  @javascript
  Scenario: Group members can see the assginment's attached rubric
    Given the user logs in
     Then the user opens the assignment task
  #   Then the user opens the 'grading' submissions tab
      And the shown rubric matches the assignment rubric
    Then the user logs out
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested
    Given the user logs in
     Then the user opens the assignment task
  #   Then the user opens the 'grading' submissions tab
      And the shown rubric matches the assignment rubric

  @javascript
  Scenario: Team member can submit text and a teammate can revise that text
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'text' submission
     Then the user clicks 'Save revision for further editing'
     Then the assignment has 1 'draft' submission
     Then the assignment has 0 'submitted' submission
      And the 'latest' db submission data is accurate
     Then the 'submitter' is the 'current' user
     Then the 'creator' is the 'current' user
     Then remember the 'submitter' user
     Then remember the 'creator' user
    Then the user logs out
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user opens submission 1
     Then the user enters a 'text' submission
     Then the user clicks 'Save revision for further editing'
     Then remember the 'submitter' user
     Then the assignment has 1 'draft' submission
     Then the assignment has 0 'submitted' submission
      And the 'latest' db submission data is accurate
     Then the 'submitter' is the 'current' user
     Then the 'creator' is the 'remembered' user
     Then the user logs out
    Given the user is the "random" user in the group
    Given the user "has" had demographics requested
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user opens submission 1
     Then the user clicks 'Submit revision for grading'
     Then remember the 'submitter' user
     Then the assignment has 1 'submitted' submission
     Then the assignment has 0 'draft' submission

  @javascript
  Scenario: Group member can open and submit a link to a group assignment
  #@javascript
  #Scenario: Group member can open and submit files to a group assignment
  @javascript
  Scenario: Group member can open and submit links to a group assignment
  @javascript
  Scenario: User can open and submit a combo to a group assignment
  @javascript
  Scenario: User can submit a combo to a group assignment before the first deadline
  @javascript
  Scenario: User can submit a combo to a group assignment after the first deadline but before the final
  @javascript
  Scenario: User cannot submit to a group assignment after the final deadline
  @javascript
  Scenario: Different users can submit and re-submit text" to a group assignment
  @javascript
  Scenario: Different users can submit and re-submit a file to a group assignment
  @javascript
  Scenario: Different users can submit and re-submit a link to a group assignment
  @javascript
  Scenario: Different users can submit and re-submit a combo to a group assignment
  @javascript
  Scenario: Different users can submit then withdraw a submitted assignment


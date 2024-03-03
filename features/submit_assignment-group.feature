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
    Given the users "have" had demographics requested

  @javascript
  Scenario: User should not be able to see an inactive assignment
    Given the assignment "is not" initialized active
    Given the user logs in
    Then user should see 0 open task
    Then the user logs out
    Then the user is the "random" user in the group
    Then the user logs in
    Then user should see 0 open task

  @javascript
  Scenario: User should not be able to see a closed group assignment
    Given the course is shifted 2 'years' into the 'past'
    Given the user logs in
    Then user should see 0 open task
    Then the user logs out
    Given the user is the "random" user in the group
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
    Given the user logs in
     Then the user opens the assignment task
  #   Then the user opens the 'grading' submissions tab
      And the shown rubric matches the assignment rubric

  @javascript
  Scenario: Team member can submit text and a teammate can revise that text
    Given the user is the "random" user in the group
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user creates a new submission
     Then the user enters a 'text' submission
     Then the user clicks 'Save revision for further editing'
     Then remember the 'submitter' user
     Then remember the 'creator' user
     Then the assignment has 1 'draft' submission
     Then the assignment has 0 'submitted' submission
      And the 'latest' db submission data is accurate
     Then the 'submitter' is the 'current' user
     Then the 'creator' is the 'current' user
     Then remember the 'submitter' user
     Then remember the 'creator' user
    Then the user logs out
    # User #2
    Given the user is the "random" user in the group
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
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user opens submission 1
     Then the user clicks 'Submit revision for grading'
     Then remember the 'submitter' user
     Then the assignment has 1 'submitted' submission
     Then the assignment has 0 'draft' submission

  @javascript
  Scenario: Any team member can withdraw a submitted assignment
    Given the user is the "random" user in the group
      And the assignment already has 4 submission from the user
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user withdraws submission 3
     Then the assignment has 1 'withdrawn' submission
     Then the assignment has 3 'active' submission
     Then the user logs out
    # Teammate #2
    Given the user is the "random" user in the group
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user withdraws submission 1
     Then the assignment has 2 'withdrawn' submission
     Then the assignment has 2 'active' submission


  @javascript
  Scenario: Any team member cannot withdraw a graded assignment
    Given the assignment already has 4 submission from the user
      And submission 2 'is' graded
    Given the user is the "random" user in the group
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user 'can' withdraw submission 1
     Then the user 'can' withdraw submission 3
     Then the user 'cannot' withdraw submission 2
     Then the user logs out
     # Teammate #2
    Given the user is the "random" user in the group
    Given the user logs in
     Then the user opens the assignment task
     Then the user opens the 'Submissions' submissions tab
     Then the user 'can' withdraw submission 1
     Then the user 'can' withdraw submission 3
     Then the user 'cannot' withdraw submission 2
     Then the user logs out

  @javascript
  Scenario: Any team member cannot withdraw a closed assignment
    Given the assignment already has 4 submission from the user
    Given today is after the final deadline
    Given the user is the "random" user in the group
    Given the user logs in
     Then user should see 0 open task
     Then user opens their profile
     Then user sees the assignment in the history
     Then the user opens the assignment history item
     Then the 'Submissions' tab 'is not' enabled
     Then the user logs out
     # Teammate #2
    Given the user is the "random" user in the group
    Given the user logs in
     Then user should see 0 open task
     Then user opens their profile
     Then user sees the assignment in the history
     Then the user opens the assignment history item
     Then the 'Submissions' tab 'is not' enabled
     Then the user logs out
  
  @javascript
  Scenario: No team member can submit an assignment that is closed
    Given the course is shifted 2 'months' into the 'future'
    Given the assignment "is" initialized active
    Given the user logs in
     Then the user opens the assignment task
     Then the 'Submissions' tab 'is not' enabled
     Then the user logs out
     # Teammate #2
    Given the user is the "random" user in the group
    Given the user logs in
     Then the user opens the assignment task
     Then the 'Submissions' tab 'is not' enabled
  
  @javascript
  Scenario: No team member can see another team's submission
    Given the assignment already has 4 submission from the user
    Given the project has a group with 4 confirmed users
    Given the user is the "random" user in the group
    Given the assignment already has 4 submission from the user
    Given the user logs in
     Then the user opens the assignment task
     Then the user sees 4 submissions
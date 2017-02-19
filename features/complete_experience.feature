Feature: Users can complete 'experiences'
  Users must be able to access and react to experiences.

  Background:
    Given there is a course with an experience
    Given the experience "has" been activated
    Given the course has 4 confirmed users
    Given the user is "a random" user
    Given the experience started "last month" and ends "next month"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    When the user logs in
    Then the user should see a successful login message

  Scenario: The student should not be able to proceed without selecting a behavior
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
     And the user presses "Save and continue"
    Then the user will see "Week 1"
    Then the user will see "You must select a behavior"

  Scenario: The participant should not be able to proceed without selecting a behavior and comments should remain
    Then they enter "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment " in the field "Click here if you have additional comments for us regarding this narrative."
     And the user presses "Save and continue"
    Then the user will see "Week 1"
    Then the user will see "You must select a behavior"
    Then in the field "Click here if you have additional comments for us regarding this narrative." they will see "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment "

  Scenario: instructions are only presented when users first begin an experience
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user logs out
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user will see "Week 1"

  Scenario: Participant should be able to record Group domination
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
    Then the user chooses the "Group domination" radio button
    Then the user presses "Save and continue"
     And the database will show a new week 1 "Group domination" diagnosis from the user

  Scenario: Participant should be able to record Equal participation
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
    Then the user chooses the "Equal participation" radio button
    Then the user presses "Save and continue"
     And the database will show a new week 1 "Equal participation" diagnosis from the user

  Scenario: Participant should be able to record Social loafing
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
    Then the user chooses the "Social loafing" radio button
    Then the user presses "Save and continue"
     And the database will show a new week 1 "Social loafing" diagnosis from the user

  Scenario: Participant should be able to record Ganging up on the task
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
    Then the user chooses the "Ganging up on the task" radio button
    Then the user presses "Save and continue"
     And the database will show a new week 1 "Ganging up on the task" diagnosis from the user

  Scenario: Participant should be able to record I don't know
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
    Then the user chooses the "I don't know" radio button
    Then the user presses "Save and continue"
     And the database will show a new week 1 "I don't know" diagnosis from the user

  Scenario: Participant should be able to record Other
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
    Then the user chooses the "Other" radio button
    Then they enter "super behavior" in the field "What behavior did you see?"
    Then the user presses "Save and continue"
     And the database will show a new week 1 "Other" diagnosis from the user
     And the latest Diagnosis will show "super behavior" in the field "other_name"

  Scenario: Participant completes fourteen weeks
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week

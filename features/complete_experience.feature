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
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then they enter "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment" in extant field "Your comments:"
     And the user presses "Save and continue"
    Then the user will see "Week 1"
    Then the user will see "You must select a behavior"
    Then in the field "Your comments:" they will see "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment"

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
    Then they enter "super behavior" in extant field "What behavior did you see?"
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

  Scenario: Participant completes a full experience
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
    Then the user will see "Overall Group Behavior"
    Then the user chooses the "Social loafing" radio button
    Then they enter "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment" in extant field "Your suggestions:"
    Then the user presses hidden "Submit"
     And the database will show a reaction with "Social loafing" as the behavior
     And the database will show a reaction with improvements of "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment"
    Then the user will see "Your reaction to the experience was recorded"
    Then user should see 1 open task
    Then the user will see "Completed"

  Scenario: Participant cannot complete an experience without improvements
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
    Then the user will see "Overall Group Behavior"
    Then the user chooses the "Social loafing" radio button
    Then the user presses hidden "Submit"
    Then the user will see "Reflection on possible improvements is required"

  Scenario: Participant cannot complete an experience without improvements
    Then the user logs out
    Given the user is "the first" user
    When the user logs in
    Then the user should see a successful login message
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
    Then the user logs out

    #switch to another user
    Given the user is "the last" user
    When the user logs in
    Then the user should see a successful login message
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
    Then the user logs out

    Given the user is "the first" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user will see "Overall Group Behavior"
    Then the user chooses the "Social loafing" radio button
    Then the user presses hidden "Submit"
    Then the user will see "Reflection on possible improvements is required"
    Then the user will see "Overall Group Behavior"
    Then the user chooses the "Ganging up on the task" radio button
    Then they enter "first comment" in extant field "Your suggestions:"
    Then the user presses hidden "Submit"
     And the database will show a reaction with "Ganging up on the task" as the behavior
     And the database will show a reaction with improvements of "first comment"
    Then the user will see "Your reaction to the experience was recorded"
    Then user should see 1 open task
    Then the user will see "Completed"

    Given the user is "the last" user
    When the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user completes a week
    Then the user will see "Overall Group Behavior"
    Then the user chooses the "Group domination" radio button
    Then they enter "second comment" in extant field "Your suggestions:"
    Then the user presses hidden "Submit"
     And the database will show a reaction with "Group domination on the task" as the behavior
     And the database will show a reaction with improvements of "second comment"
    Then the user will see "Your reaction to the experience was recorded"
    Then user should see 1 open task
    Then the user will see "Completed"
    
    Then there will be 2 reactions from 2 different scenarios recorded
    Then there will be 2 reactions from 2 different narratives recorded

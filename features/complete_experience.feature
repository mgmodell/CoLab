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
    Then there will be 1 reactions from 1 different scenarios recorded
    Then there will be 1 reactions from 1 different narratives recorded

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
    Then there will be 1 reactions from 1 different scenarios recorded
    Then there will be 1 reactions from 1 different narratives recorded

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

  Scenario: Interleaved users
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

    #switch back to the original user
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
     And the database will show a reaction for the user with "Ganging up on the task" as the behavior
     And the database will show a reaction for the user with improvements of "first comment"
    Then the user will see "Your reaction to the experience was recorded"
    Then user should see 1 open task
    Then the user will see "Completed"
    Then the user logs out

    #switch to the other user
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
     And the database will show a reaction with "Group domination" as the behavior
     And the database will show a reaction with improvements of "second comment"
    Then the user will see "Your reaction to the experience was recorded"
    Then user should see 1 open task
    Then the user will see "Completed"
    
    Then there will be 2 reactions from 2 different narratives recorded
    Then there will be 2 reactions from 2 different scenarios recorded

  Scenario: 12 students should be able to complete 14 different scenarios
     Then the user logs out
    Given the course has 8 confirmed users
    Given the users "have" had demographics requested
     Then all users complete the course successfully

    Then there will be 12 reactions from 12 different narratives recorded
    Then there will be 12 reactions from 3 different scenarios recorded

  Scenario: 1 student completes experiences for 2 courses
     Then the user logs out
    Given the experience started "last month" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for another class
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then there will be 2 reactions from 2 different narratives recorded
    Then there will be 2 reactions from 2 different scenarios recorded

  Scenario: 1 student completes 2 experiences for 1 course
     Then the user logs out
    Given the course started "January 1, 2015" and ends "January 1, 2018"
    Given today is "March 2, 2017"
    Given the experience started "March 1, 2017" and ends "March 3, 2017"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another
    Given the course has an experience
    Given today is "March 8, 2017"
    Given the experience "has" been activated
    Given the experience started "March 7, 2017" and ends "March 9, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then there will be 2 reactions from 2 different narratives recorded
    Then there will be 2 reactions from 2 different scenarios recorded

  Scenario: 1 student completes 13 experiences
     Then the user logs out
    Given the course started "January 1, 2015" and ends "January 1, 2018"
    Given the experience started "February 1, 2017" and ends "February 4, 2017"
    Given today is "February 2, 2017"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 2
    Given today is "February 7, 2017"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "February 6, 2017" and ends "February 8, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (3) for this class
    Given today is "February 10, 2017"
    Given the course has an experience
    Given the experience started "February 9, 2017" and ends "February 10, 2017"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 4
    Given today is "February 12, 2017"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "February 12, 2017" and ends "February 15, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (5) for this class
    Given today is "February 16, 2017"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 6
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (7) for this class
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 8
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (9) for this class
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 10
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (11) for this class
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 12
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (13) for this class
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    Then there will be 13 reactions from 12 different narratives recorded
    Then there will be 13 reactions from 3 different scenarios recorded

  Scenario: More than 2 students complete 13 experiences between them
     Then the user logs out
    Given the user is "the first" user
    Given the course started "January 1, 2015" and ends "January 1, 2018"
    Given the experience started "February 1, 2017" and ends "February 4, 2017"
    Given today is "February 2, 2017"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 2
    Given the user is "the last" user
    Given today is "February 7, 2017"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "February 6, 2017" and ends "February 8, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (3) for this class
    Given the user is "the first" user
    Given the user enrolls in the course
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 4
    Given the user is "the last" user
    Given today is "February 12, 2017"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "February 12, 2017" and ends "February 15, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (5) for this class
    Given the user is "the first" user
    Given the user enrolls in the course
    Given today is "February 16, 2017"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 6
    Given the user is "a random" user
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (7) for this class
    Given the user is "the last" user
    Given the user enrolls in the course
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 8
    Given the user is "the first" user
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (9) for this class
    Given the user is "a random" user
    Given the user enrolls in the course
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 10
    Given the user is "the last" user
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (11) for this class
    Given the user is "the first" user
    Given the user enrolls in the course
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 12
    Given the user is "the last" user
    Given today is "3 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "tomorrow"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (13) for this class
    Given the user is "a random" user
    Given the user enrolls in the course
    Given today is "3 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "tomorrow"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    Then there will be 13 reactions from 3 different scenarios recorded
    Then no user will have reacted to the same narrative more than once
    Then there will be 13 reactions from 12 different narratives recorded

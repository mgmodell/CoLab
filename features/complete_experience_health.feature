Feature: Users can complete 'experiences' with health
  Users must be able to access and react to experiences.

  Background:
    Given there is a course with an experience
    Given the experience "has" been activated
    Given the course has 4 confirmed users
    Given the user is "a random" user
    Given the experience started "last month" and ends "in two months"
    Given the experience "has" been activated
    Given the experience "does" support "health"
    Given the experience "does not" support "SAPA"
    Given the users "have" had demographics requested
    When the user logs in
    Then the user should see a successful login message

  Scenario: The student should not be able to proceed without selecting a behavior
    Given the course has a consent form
    Given the consent form started "1 month ago" and ends "1 month from now"
    Given the consent form "is" active
    Given the consent form "has" been presented to the user
    When the user visits the index
    Then user should see 1 open task
    Then user should see a consent form listed for the open experience
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
     And the user presses "Save and continue"
    Then the user will see "Week 1"
    Then the user will see "You must select a behavior"
    Then user opens their profile
    Then the user sees the experience in the history

  Scenario: The student should not be able to proceed without selecting a behavior
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then the user will see "Week 1"
     And the user presses "Save and continue"
    Then the user will see "Week 1"
    Then the user will see "You must select a behavior"
    Then user opens their profile
    Then the user sees the experience in the history

  Scenario: The dropped student should not see an experience
    Then the user logs out
    Then the user is dropped from the course
    When the user logs in
    Then the user should see a successful login message
    Then user should see 0 open task

  Scenario: The participant should not be able to proceed without selecting a behavior and comments should remain
    Then user should see 1 open task
    Then the user clicks the link to the experience
    Then the user sees the experience instructions page
     And the user presses "Next"
    Then they enter "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment" in extant field "Your comments"
     And the user presses "Save and continue"
    Then the user will see "Week 1"
    Then the user will see "You must select a behavior"
    Then in the field "Your comments" they will see "super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment super comment"

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
    Then the user will see "100%"
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
    Then the user will see "100%"
    Then user opens their profile
    Then the user sees the experience in the history
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
    Then the user will see "100%"
    
    Then there will be 2 reactions from 2 different narratives recorded
    Then there will be 2 reactions from 2 different scenarios recorded

  Scenario: 12 students should be able to complete 14 different scenarios
     Then the user logs out
    #With 8 new students, we will have 12
    Given the course has 8 confirmed users
    Given the users "have" had demographics requested
     Then all users complete the course successfully

    Then there will be 12 reactions from 12 different narratives recorded
    Then there will be 12 reactions from 3 different scenarios recorded

  Scenario: 1 student completes experiences for 2 courses
     Then the user logs out
    Given the experience started "last month" and ends "4 days hence"
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
    Given the experience started "yesterday" and ends "4 days hence"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then there will be 2 reactions from 2 different narratives recorded
    Then there will be 2 reactions from 2 different scenarios recorded

  Scenario: 1 student completes 2 experiences for 1 course
     Then the user logs out
    Given the course started "January 1, 2015" and ends "1 year hence"
    Given today is "March 1, 2017"
    Given the experience started "January 1, 2017" and ends "March 4, 2017"
    Given the experience 'lead_time' is 2
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
    Given the experience started "March 7, 2017" and ends "March 10, 2017"
    Given the experience 'lead_time' is 1
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then there will be 2 reactions from 2 different narratives recorded
    Then there will be 2 reactions from 2 different scenarios recorded

  Scenario: 1 student completes 13 experiences
     Then the user logs out
    Given the course started "January 1, 2015" and ends "1 year hence"
    Given the experience started "February 1, 2017" and ends "February 5, 2017"
    Given today is "February 1, 2017"
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
    Given the experience started "February 6, 2017" and ends "February 11, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (3) for this class
    Given today is "February 10, 2017"
    Given the course has an experience
    Given the experience started "February 9, 2017" and ends "February 14, 2017"
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
    Given the experience started "February 12, 2017" and ends "February 16, 2017"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (5) for this class
    Given today is "February 16, 2017"
    Given the course has an experience
    Given the experience started "yesterday" and ends "February 20, 2017"
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
    Given the experience started "yesterday" and ends "7 days hence"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (7) for this class
    Given today is "5 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "6 days hence"
    Given the experience 'lead_time' is 2
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 8
    Given today is "5 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "7 days hence"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (9) for this class
    Given today is "5 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "7 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 10
    Given today is "4 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "7 days hence"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (11) for this class
    Given today is "4 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "7 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 12
    Given today is "4 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience "has" been activated
    Given the experience started "yesterday" and ends "7 days hence"
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (13) for this class
    Given today is "4 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "7 days hence"
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
    Given the course started "January 1, 2015" and ends "1 year hence"
    Given the experience started "February 1, 2017" and ends "February 6, 2017"
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
    Given the experience started "February 6, 2017" and ends "February 11, 2017"
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
    Given the experience started "February 12, 2017" and ends "February 16, 2017"
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
    Given the experience 'lead_time' is 0
    Given the experience started "yesterday" and ends "4 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 6
    Given the user is "a random" user
    Given today is "4 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience 'lead_time' is 0
    Given the experience started "yesterday" and ends "2 days hence"
    Given the experience "has" been activated
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
    Given the experience 'lead_time' is 0
    Given the experience started "yesterday" and ends "3 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 8
    Given the user is "the first" user
    Given today is "5 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience 'lead_time' is 0
    Given the experience started "yesterday" and ends "4 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (9) for this class
    Given the user is "a random" user
    Given the user enrolls in the course
    Given today is "5 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "4 days hence"
    Given the experience 'lead_time' is 0
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 10
    Given the user is "the last" user
    Given today is "5 days hence"
    Given the user enrolls in a new course
    Given the course has an experience
    #Given the experience 'lead_time' is 0
    Given the experience started "yesterday" and ends "4 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (11) for this class
    Given the user is "the first" user
    Given the user enrolls in the course
    Given today is "5 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "3 days hence"
    Given the experience 'lead_time' is 0
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Now for class 12
    Given the user is "the last" user
    Given today is "5 days from now"
    Given the user enrolls in a new course
    Given the course has an experience
    Given the experience 'lead_time' is 0
    Given the experience started "yesterday" and ends "3 days hence"
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    #Let's start another experience (13) for this class
    Given the user is "a random" user
    Given the user enrolls in the course
    Given today is "7 days hence"
    Given the course has an experience
    Given the experience started "yesterday" and ends "3 days hence"
    Given the experience 'lead_time' is 0
    Given the experience "has" been activated
    Then the user logs in
    Then the user should see a successful login message
    Then user should see 1 open task
    Then the user successfully completes an experience
    Then the user logs out

    Then there will be 13 reactions from 3 different scenarios recorded
    Then no user will have reacted to the same narrative more than once

  Scenario: More than 2 students complete 48 experiences between them
     Then the user logs out
    #With 44 new students, we will have 48
    Given the course has 44 confirmed users
    Given the users "have" had demographics requested
     Then all users complete the course successfully

    Then there will be 48 reactions from 12 different narratives recorded
    Then there will be 48 reactions from 3 different scenarios recorded

  Scenario: More than 2 students complete 96 experiences between 3 classes
     Then the user logs out
    #With 8 new students, we will have 12
    Given the course has 28 confirmed users
    Given the users "have" had demographics requested
     Then all users complete the course successfully

    Given there is a course with an experience
    Given the experience started "last month" and ends "5 days hence"
    Given the experience "has" been activated
    Given the course has 32 confirmed users
    Given the users "have" had demographics requested
     Then all users complete the course successfully

    Given there is a course with an experience
    Given the experience started "last month" and ends "5 days hence"
    Given the experience "has" been activated
    Given the course has 32 confirmed users
    Given the users "have" had demographics requested
     Then all users complete the course successfully

    Then there will be 96 reactions from 12 different narratives recorded
    Then there will be 96 reactions from 3 different scenarios recorded

  Scenario: A course with four users deploys 4 experiences will see 12 narratives and 3 scenarios recorded
     Then the user logs out
    Given the experience started "last month" and ends "4 days hence"
    Given the experience "has" been activated

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #experience 2
    Given the course has an experience
    Given the experience started "3 days from now" and ends "9 days from now"
    Given the experience "has" been activated
    Given today is "5 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #experience 3
    Given the course has an experience
    Given the experience started "10 days from now" and ends "20 days from now"
    Given the experience "has" been activated
    Given today is "15 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #experience 4
    Given the course has an experience
    Given the experience started "23 days from now" and ends "29 days from now"
    Given the experience "has" been activated
    Given today is "25 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out


    Then there will be 16 reactions from at least 10 different narratives recorded
    Then there will be 16 reactions from 3 different scenarios recorded

Feature: Submitting Candidate words for Bingo!
  Students must be able to reach and submit their words for Bingo!

  Background:
    Given there is a course with an assessed project
    Given there is a course with an assessed project
    Given the course started "two months ago" and ended "two months from now"
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the project has a group with 4 confirmed users
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated
    Given the user is the "first" user in the group
    Given the user "has" had demographics requested

  Scenario: All group members are informed of a collaboration request
    Given the user logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user will see 10 term field sets
     Then the candidate entries should be empty
     Then the user "should not" see they're waiting on a collaboration response
     Then the user "should not" see collaboration was requested
     When the user requests collaboration
    Given the user logs out
     #user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should not" see they're waiting on a collaboration response
     Then the user "should" see collaboration was requested
    Given the user logs out
     #user 1
     When group user 1 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see they're waiting on a collaboration response
    Given the user logs out
     #user 3
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
    Given the user logs out
     #user 4
     When group user 4 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
    Given the user logs out

  Scenario: A single member declining collaboration cancels the request
    Given the user logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user will see 10 term field sets
     Then the candidate entries should be empty
     Then the user "should not" see collaboration was requested
     When the user requests collaboration
    Given the user logs out
     #user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 3
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 4
     When group user 4 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "declines" the collaboration request
    Given the user logs out
     #user 1
     When group user 1 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should not" see collaboration was requested
    Given the user logs out
     #user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should not" see collaboration was requested
    Given the user logs out

  Scenario: If all group members accept collaboration, the CL is merged.
    Given the user logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user will see 10 term field sets
     Then the candidate entries should be empty
     Then the user "should not" see collaboration was requested
     When the user requests collaboration
    Given the user logs out
     #user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 3
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 4
     When group user 4 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 1
     When group user 1 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button
     Then the user will see 36 term field sets
     Then the candidate entries should be empty
    Given the user logs out
     #user 3
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button
     Then the candidate lists have been merged
     Then the user will see 36 term field sets
     Then the candidate entries should be empty
    Given the user logs out

  Scenario: If all group members accept collaboration, the CL is merged including their terms.
    Given the user logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     When the user populates 3 of the "term" entries
      And the user populates 3 of the "definition" entries
     Then the user clicks "Save"
     Then the user will see "success"
     Then the user logs out
     #user 3
     When group user 3 logs in
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     When the user populates 3 of the "term" entries
      And the user populates 3 of the "definition" entries
     Then the user clicks "Save"
     Then the user will see "success"
     When the user requests collaboration
    Given the user logs out
    #Let's have everyone accept now
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see they're waiting on a collaboration response
    Given the user logs out
    #Let's have user 4
     When group user 4 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
    #Let's have user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
    #Let's have user 1
     When group user 1 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
     Then the candidate lists have been merged
     Then the user will see 36 term field sets
    Then the candidate list entries should match the list


  Scenario: All group members attached to a CL see and can change the CL
    Given the user logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user will see 10 term field sets
     Then the candidate entries should be empty
     Then the user "should not" see collaboration was requested
     When the user requests collaboration
    Given the user logs out
     #user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 3
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 4
     When group user 4 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user "should" see collaboration was requested
     Then the user "accepts" the collaboration request
    Given the user logs out
     #user 1
     When group user 1 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button
     Then the user will see 36 term field sets
     Then the candidate lists have been merged
     When the user populates 3 of the "term" entries
      And the user populates 3 of the "definition" entries
     Then the user clicks "Save"
     Then the user will see "success"
     Then retrieve the latest Bingo! game from the db
     Then the candidate list entries should match the list
    Given the user logs out
     #user 2
     When group user 2 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button
     Then the user will see 36 term field sets
     When the user populates 4 of the "term" entries
      And the user populates 4 of the "definition" entries
     Then the user clicks "Save"
     Then the user will see "success"
     Then retrieve the latest Bingo! game from the db
     Then the candidate list entries should match the list
    Given the user logs out
     #user 3
     When group user 3 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button
     Then the user will see 36 term field sets
     When the user populates 4 additional "term" entries
      And the user populates 4 additional "definition" entries
     Then the user clicks "Save"
     Then the user will see "success"
     Then retrieve the latest Bingo! game from the db
     Then the candidate list entries should match the list
    Given the user logs out
     #user 4
     When group user 4 logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button
     Then the user will see 36 term field sets
     When the user changes the first 4 "term" entries
     When the user changes the first 4 "definition" entries
     Then the user clicks "Save"
     Then the user will see "success"
     Then retrieve the latest Bingo! game from the db
     Then the candidate list entries should match the list
    Given the user logs out

  Scenario: A student who is not in a group will not see the group options
    Given the course has 4 confirmed users
    Given the user is "a random" user
    Given the user logs in
     Then user should see 1 open task
     When the user clicks the link to the candidate list
     Then the user should see the Bingo candidate list
     Then the user will see 10 term field sets
     Then the candidate entries should be empty
     Then the user "should not" see they're waiting on a collaboration response
     Then the user "should not" see collaboration was requested
     Then the user "should not" see collaboration request button

  Scenario: Moving a student between groups properly assigns their group buttons on current CLs
    #Basically, run through open CLs and make sure they see any group CLs 

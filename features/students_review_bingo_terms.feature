Feature: Students review Candidate words for Bingo!
  Students must be able to review words submitted for Bingo! play

  Background:
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 5
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! is group-enabled with the project and a 20 percent group discount
    Given the Bingo! "has" been activated

    #set up the users and have them complete the bingo! prep assignment
    Given the project has a group with 4 confirmed users
     Then remember 2 group members
    Given the users "finish" prep "as a group"
    # 36 terms
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as individuals"
    # 40 terms
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as individuals"
    # 20
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as a group"
    # 18
    Given the project has a group with 4 confirmed users
    Given the users "don't" prep "as a group"
    # 0
    Given the course has 4 confirmed users
    Given the users "incomplete" prep "as individuals"
    # 20

    #Instructor time!
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review

  @javascript
  Scenario: Instructor completes the review and the user checks their account
    Given the user assigns "Accept" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then user opens their profile
     Then user sees the Bingo! in the history
     Given today is "4 days from now"
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 0 open task
     Then user opens their profile
     Then user sees the Bingo! in the history

  @javascript
  Scenario: Instructor logs in and accepts all candidates
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the user should see 4 concepts
     Then the concept list should match the list
     
  @javascript
  Scenario: Instructor logs in and assigns term feedback to candidates
    Given the user sees review items for all the expected candidates
    Given the user assigns "Term" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the user should see 0 concepts
     Then the concept list should match the list

  @javascript
  Scenario: Instructor reviews, user is dropped and re-added
    Given the user sees review items for all the expected candidates
    Given the user assigns "" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is remembered group member 1
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the user remembers group performance
     Then the concept list should match the list
     Then the user logs out
     Then the user is dropped from the course
     When the user is remembered group member 2
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the users performance matches original group performance
     Then the concept list should match the list
     Then the user logs out
     Then the cached performance is erased
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the users performance matches original group performance
     Then the concept list should match the list
     Then the user logs out
     When the user is remembered group member 1
     Then the user is added to the course
     When the user is remembered group member 2
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the users performance matches original group performance
     Then the concept list should match the list

  @javascript
  Scenario: Instructor logs in and assigns definition feedback to candidates
    Given the user sees review items for all the expected candidates
    Given the user assigns "Definition" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the user should see 4 concepts
     Then the concept list should match the list

  @javascript
  Scenario: Instructor logs in and assigns mixed feedback to candidates
    Given the user sees review items for all the expected candidates
    # Assign any sort of feedback
    Given the user assigns "" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the concept list should match the list
     Then the user logs out
     # Let's try again tomorrow
     Given today is "3 days from now"
     When the user is any student in the course
     Then the user logs in
     Then user should see 0 open task

  @javascript
  Scenario: Instructor assigns mixed feedback to 2 courses successively
    Given the user sees review items for all the expected candidates
    # Assign any sort of feedback
    Given the user assigns "" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the concept list should match the list
     Then the user logs out

    #Course 2
    Given there is a course with an assessed project
    Given the course started "two months ago" and ended "two months from now"
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "5 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated

    #set up the users and have them complete the bingo! prep assignment
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as a group"
    # 36 terms

    #Instructor time!
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    Given today is "4 days from now"
     Then the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    # Assign any sort of feedback
    Given the user assigns "" feedback to all candidates
    Given the user checks the review completed checkbox
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     When the user is any student in the course
     Then the user logs in
     Then user should see 1 open task
     Then the user clicks the link to the concept list
     Then the concept list should match the list
     Then the number of concepts is less than the total number of concepts
     Then the user logs out

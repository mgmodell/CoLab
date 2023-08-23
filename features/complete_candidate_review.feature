Feature: Review Candidate words for Bingo!
  Instructors must be able to review words submitted for Bingo! play

  Background:
    Given there is a course with an assessed project
    Given the course started "two months ago" and ended "two months from now"
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 6
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! is group-enabled with the project and a 50 percent group discount
    Given the Bingo! "has" been activated

    #set up the users and have them complete the bingo! prep assignment
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as a group"
    # 16 terms
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as individuals"
    # 20 terms
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as individuals"
    # 10
    Given the project has a group with 4 confirmed users
    Given the users "incomplete" prep "as a group"
    # 8
    Given the project has a group with 4 confirmed users
    Given the users "don't" prep "as a group"
    # 0
    Given the course has 4 confirmed users
    Given the users "incomplete" prep "as individuals"
    # 10

    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course

  @javascript
  Scenario: Student does not see a Bingo! in review
    Given today is "tomorrow"
    Given the user is any student in the course
    Given the user logs in
     Then user should see 0 open task

  @javascript
  Scenario: Instructor does not see the review until the prep time
    Given the user logs in
     Then user should see 0 open task

  @javascript
  Scenario: Instructor sees 66 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
     Then the user sees 66 candidate items for review

  @javascript
  Scenario: Instructor logs in and assigns feedback to candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user assigns "Accept" feedback to all candidates
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user will see "success"
     Then the user logs out
     Then the user logs in
     Then the user will see "100%"

  @javascript
  Scenario: Instructor logs in and accepts all candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 24 emails will be sent
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

  @javascript
  Scenario: Instructor logs in and assigns term feedback to candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Term" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the saved reviews match the list
     Then there will be 0 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

  @javascript
  Scenario: Instructor logs in and assigns definition feedback to candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Definition" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 24 emails will be sent
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

  @javascript
  Scenario: Instructor logs in and assigns mixed feedback to candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    # Assign any sort of feedback
    Given the user assigns "" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 24 emails will be sent
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

  @javascript
  Scenario: Instructor logs in and accepts then lowercases all concepts
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     Then the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user lowercases "all" concepts
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 24 emails will be sent
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

  @javascript
  Scenario: Instructor logs in and accepts then lowercases some concepts
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then the user logs out
     Then the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user lowercases "some" concepts
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 24 emails will be sent
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

  @javascript
  Scenario: The system handles 2 Bingo! games
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 24 emails will be sent
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

    #Create a new project
    Given there is a course with an assessed project
    Given the course started "two months ago" and ended "two months from now"
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "5 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated
     Then the user logs out

    #set up the users and have them complete the bingo! prep assignment
    Given the project has a group with 4 confirmed users
    Given the users "finish" prep "as a group"
    # 36 terms
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course
    #let's review bingo 2
    Given today is "4 days from now"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the user waits while seeing "Saving feedback."
     Then 28 emails will be sent
     Then the saved reviews match the list
     Then there will be 8 concepts
     Then the user will see "success"
     Then the user navigates home
     Then user should see 0 open task

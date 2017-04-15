Feature: Review Candidate words for Bingo!
  Instructors must be able to review words submitted for Bingo! play

  Background:
    Given there is a course with an assessed project
    Given the course started "two months ago" and ended "two months from now"
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 10
    Given the Bingo! started "last month" and ends "2 days from now"
    Given the Bingo! is group-enabled with the project and a 10 percent group discount
    Given the Bingo! "has" been activated

    #set up the users and have them complete the bingo! prep assignment
    Given the project has a group with 4 confirmed users
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

    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user "has" had demographics requested
    Given the user is the instructor for the course

  Scenario: Instructor does not see the review until the prep time
    Given the user logs in
     Then user should see 0 open task

  Scenario: Instructor sees 134 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
     Then the user sees 134 candidate items for review

  Scenario: Instructor logs in and assigns feedback to 134 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user assigns "Accept" feedback to all candidates
     Then the user clicks "Save"
     Then the user will see "success"
     Then user should see 1 open task
     Then the user will see "100%"

  Scenario: Instructor logs in and accepts all 134 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Accept" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then user should see 0 open task

  Scenario: Instructor logs in and assigns term feedback to 134 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Term" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the saved reviews match the list
     Then there will be 0 concepts
     Then the user will see "success"
     Then user should see 0 open task

  Scenario: Instructor logs in and assigns definition feedback to 134 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    Given the user assigns "Definition" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then user should see 0 open task

  Scenario: Instructor logs in and assigns mixed feedback to 134 candidates
    Given today is "tomorrow"
    Given the user logs in
     Then user should see 1 open task
    Given the user clicks the link to the candidate review
    Given the user sees review items for all the expected candidates
    # Assign any sort of feedback
    Given the user assigns "" feedback to all candidates
    Given the user checks "Review completed"
     Then the user clicks "Save"
     Then the saved reviews match the list
     Then there will be 4 concepts
     Then the user will see "success"
     Then user should see 0 open task

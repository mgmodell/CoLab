Feature: Score Bingo Worksheet with Image Upload
  In order to provide feedback on student worksheet submissions,
  Instructors must be able to score worksheets and upload result images.
  The uploaded image must be stored in Active Storage and displayed in both
  the scoring view and the student's BingoBuilder.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the project started "last month" and ends "next month", opened "3 days ago" and closes "yesterday"
    Given the course started "two months ago" and ended "two months from now"
    Given the course has a Bingo! game
    Given the Bingo! game individual count is 5
    Given the Bingo! started "last month" and ends "3 days from now"
    Given the Bingo! "has" been activated
    Given the project has a group with 4 confirmed users
    Given there is a student with a bingo worksheet board

  @javascript
  Scenario: Instructor scores a worksheet with an image upload and the image is stored
    Given the user is the instructor for the course
    Given the user logs in
    When the instructor visits the worksheet score page
    Then the instructor sees the worksheet scoring form
    When the instructor sets the score to 85
    When the instructor uploads a result image
    When the instructor submits the score
    Then the scored worksheet has an image stored in Active Storage
    Then the instructor sees the result image on the score page

  @javascript
  Scenario: Student sees the scored image in BingoBuilder after instructor uploads it
    Given the worksheet board has a scored image attached
    Given the user is a student with the scored worksheet
    Given the user logs in
    When the user clicks the link to the concept list
    Then the user switches to the "Worksheet results" tab
    Then the user sees the scored result image

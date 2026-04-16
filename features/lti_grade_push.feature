Feature: LTI Grade Push
  Test the ability to configure LTI connections and push grades
  for Terms Lists (BingoGames), Experiences, and Projects.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course has a Bingo! game
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the project started "5/10/1976" and ends "11/01/2012", opened "Saturday" and closes "Monday"
    Given the Bingo! started "2/29/1980" and ends "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"
    Given the user is the instructor for the course
    Given the user logs in

  @javascript
  Scenario: Instructor configures an LTI connection for a Terms List (BingoGame)
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user clicks on the existing bingo game
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Not configured"
    Then the user sets the "LMS Line Item URL" field to "https://lms.example.com/api/lti/line_items/1"
    Then the user sets the "AGS Access Token URL" field to "https://lms.example.com/login/oauth2/token"
    Then the user sets the "Client ID" field to "client-abc-123"
    Then the user sets the "Deployment ID" field to "deploy-001"
    Then the user sets the "Issuer (iss)" field to "https://lms.example.com"
    Then close all messages
    Then the user clicks "Save LTI Connection"
    Then the user waits to see "saved successfully"
    Then close all messages
    Then retrieve the latest Bingo! game from the db
    Then the lti connection for the bingo game has "line_item_url" of "https://lms.example.com/api/lti/line_items/1"
    Then the lti connection for the bingo game has "ags_access_token_url" of "https://lms.example.com/login/oauth2/token"
    Then the lti connection for the bingo game has "client_id" of "client-abc-123"
    Then the lti connection for the bingo game has "deployment_id" of "deploy-001"
    Then the lti connection for the bingo game has "iss" of "https://lms.example.com"
    Then the user sees the LTI connection status is "Connected"

  @javascript
  Scenario: Instructor updates an LTI connection for a Terms List (BingoGame)
    Given the bingo game has an LTI connection configured
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user clicks on the existing bingo game
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Connected"
    Then the user sets the "LMS Line Item URL" field to "https://updated-lms.example.com/api/lti/line_items/2"
    Then close all messages
    Then the user clicks "Save LTI Connection"
    Then the user waits to see "saved successfully"
    Then close all messages
    Then retrieve the latest Bingo! game from the db
    Then the lti connection for the bingo game has "line_item_url" of "https://updated-lms.example.com/api/lti/line_items/2"

  @javascript
  Scenario: Instructor pushes grades for a Terms List (BingoGame) to the LMS
    Given the bingo game has an LTI connection configured
    Given the LMS grade push endpoint is available
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user clicks on the existing bingo game
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Connected"
    Then the user clicks "Push Grades to LMS"
    Then the user confirms the grade push dialog
    Then the user waits to see "Successfully pushed"
    Then close all messages

  @javascript
  Scenario: Instructor configures an LTI connection for an Experience
    Given the course has an experience
    Given the experience started "2/29/1980" and ends "7/10/2008"
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Not configured"
    Then the user sets the "LMS Line Item URL" field to "https://lms.example.com/api/lti/line_items/10"
    Then the user sets the "AGS Access Token URL" field to "https://lms.example.com/login/oauth2/token"
    Then the user sets the "Client ID" field to "exp-client-789"
    Then close all messages
    Then the user clicks "Save LTI Connection"
    Then the user waits to see "saved successfully"
    Then close all messages
    Then retrieve the latest Experience from the db
    Then the lti connection for the experience has "line_item_url" of "https://lms.example.com/api/lti/line_items/10"
    Then the lti connection for the experience has "client_id" of "exp-client-789"
    Then the user sees the LTI connection status is "Connected"

  @javascript
  Scenario: Instructor updates an LTI connection for an Experience
    Given the course has an experience
    Given the experience started "2/29/1980" and ends "7/10/2008"
    Given the experience has an LTI connection configured
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Connected"
    Then the user sets the "Client ID" field to "updated-exp-client"
    Then close all messages
    Then the user clicks "Save LTI Connection"
    Then the user waits to see "saved successfully"
    Then close all messages
    Then retrieve the latest Experience from the db
    Then the lti connection for the experience has "client_id" of "updated-exp-client"

  @javascript
  Scenario: Instructor pushes grades for an Experience to the LMS
    Given the course has an experience
    Given the experience started "2/29/1980" and ends "7/10/2008"
    Given the experience has an LTI connection configured
    Given the LMS grade push endpoint is available
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user switches to the "Activities" tab
    Then the user edits the existing experience
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Connected"
    Then the user clicks "Push Grades to LMS"
    Then the user confirms the grade push dialog
    Then the user waits to see "Successfully pushed"
    Then close all messages

  @javascript
  Scenario: Instructor configures an LTI connection for a Project
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks on the existing project
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Not configured"
    Then the user sets the "LMS Line Item URL" field to "https://lms.example.com/api/lti/line_items/20"
    Then the user sets the "AGS Access Token URL" field to "https://lms.example.com/login/oauth2/token"
    Then the user sets the "Client ID" field to "proj-client-456"
    Then the user sets the "Deployment ID" field to "deploy-proj-001"
    Then close all messages
    Then the user clicks "Save LTI Connection"
    Then the user waits to see "saved successfully"
    Then close all messages
    Then retrieve the latest project from the db
    Then the lti connection for the project has "line_item_url" of "https://lms.example.com/api/lti/line_items/20"
    Then the lti connection for the project has "client_id" of "proj-client-456"
    Then the user sees the LTI connection status is "Connected"

  @javascript
  Scenario: Instructor updates an LTI connection for a Project
    Given the project has an LTI connection configured
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks on the existing project
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Connected"
    Then the user sets the "Deployment ID" field to "updated-deploy-002"
    Then close all messages
    Then the user clicks "Save LTI Connection"
    Then the user waits to see "saved successfully"
    Then close all messages
    Then retrieve the latest project from the db
    Then the lti connection for the project has "deployment_id" of "updated-deploy-002"

  @javascript
  Scenario: Instructor pushes grades for a Project to the LMS
    Given the project has an LTI connection configured
    Given the LMS grade push endpoint is available
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks on the existing project
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Connected"
    Then the user clicks "Push Grades to LMS"
    Then the user confirms the grade push dialog
    Then the user waits to see "Successfully pushed"
    Then close all messages

  @javascript
  Scenario: Push Grades button is disabled when LTI connection is not configured
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks on the existing project
    Then the user switches to the "LTI Grade Passback" tab
    Then the user sees the LTI connection status is "Not configured"
    Then the "Push Grades to LMS" button is disabled

Feature: Course Administration
  Test our ability to perform basic administrative
  tasks on a course.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1970" and ended "4 months hence"
    Given the project started '5/12/1976' and ends '10/01/2012'
    Given the course started "5/10/1976" and ended "11/01/2012"

  Scenario: Admin creates a new course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
     And the user clicks "New Course"
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then the user clicks "Create Course"
     And the user will see "successfully"
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is "099"
     And the course "Description" field is "I love to eat peas and carrots all day long"
     And the course start date is "tomorrow" and the end date is "next month"
     And the course "timezone" is "Nairobi"

  Scenario: Admin cannot creates an incomplete new course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
     And the user clicks "New Course"
     #no name
     And the user sets the "Name" field to ""
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then the user clicks "Create Course"
     And the user will see "Please review the problems below"
     #no start date
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "" and the end date to "next month"
    Then the user clicks "Create Course"
     And the user will see "Please review the problems below"
     #no end date
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "tomorrow" and the end date to ""
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then the user clicks "Create Course"
     And the user will see "Please review the problems below"
     #no number or description
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to ""
     And the user sets the "Description" field to ""
     And the user sets the start date to "tomorrow" and the end date to "next month"
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then the user clicks "Create Course"
     #We should have success now
     And the user will see "successfully"
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is ""
     And the course "Description" field is ""
     And the course start date is "tomorrow" and the end date is "next month"
     And the course "timezone" is "Nairobi"

  Scenario: Instructor cannot create a new course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user does not see a "New Course" link

  Scenario: Admin edits an existing course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user clicks "Edit Course Details"
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the start date to "5/11/1976" and the end date to "next month"
     And the timezone "is" "Mexico City"
     And the user sets the course timezone to "Nairobi"
    Then the user clicks "Update Course"
     And the user will see "successfully"
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is "099"
     And the course "Description" field is "I love to eat peas and carrots all day long"
     And the course start date is "5/11/1976" and the end date is "next month"
     And the course "timezone" is "Nairobi"

  Scenario: Admin adds an existing student to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Given 1 users
    Then the user adds the 'student' users 'user_list'
    Then there are 13 students in the course
    Then the users are students

  Scenario: Admin adds a new student to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'student' users 'me@mailinator.com'
    Then there are 13 students in the course

  Scenario: Admin adds existing students to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Given 5 users
    Then the user adds the 'student' users 'user_list'
    Then there are 17 students in the course
    Then the users are students

  Scenario: Admin adds new students to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'student' users 'me@mailinator.com, you@mailinator.com, myself@mailinator.com'
    Then there are 15 students in the course
    Then the users are students

  Scenario: Malformed email address returns an error
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'instructor' users 'me@mailinator.com<'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then the user adds the 'instructor' users 'me@mailinator.com>'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then the user adds the 'instructor' users 'me@12221.341.24412.2412211'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then the user adds the 'instructor' users 'me@mailinator'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then the user adds the 'instructor' users 'lme@mailinator.com eweq.wer'
    Then there are 2 instructors in the course
     And the user will see "One instructor has been invited"
    Then the user adds the 'instructor' users 'memailinator.com<'
    Then there are 2 instructors in the course
     And the user will see "Was there a typo?"

  Scenario: Admin adds an instructor to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'instructor' users 'me@mailinator.com'
    Then there are 2 instructors in the course

  Scenario: Admin adds 5 existing instructors to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user opens the course
    Given 5 users
    Then the user adds the 'instructor' users 'user_list'
    Then there are 6 instructors in the course
    Then the users are instructors

  Scenario: Admin duplicates an existing course
    Given the course started "5/10/1976" and ended "11/01/2012"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the course 'Name' is 'to dup'
    Given the course 'Number' is 'd6'
    Given the course 'Description' is 'ohla!'
    Given the course has an experience
    Given the experience started "6/20/1976" and ends "8/20/1976"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the experience "Name" is "cup"
    Given the course has a Bingo! game
    Given the Bingo! started "5/20/1976" and ends "7/20/1976"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the Bingo! "Topic" is "Private"
    Given the Bingo! "Description" is "this is neat"
    Given the Bingo! "Terms count" is 20
    Given the Bingo! prep days is 2
    Given the Bingo! project is the course's project
    Given the Bingo! percent discount is 30
    Given the Bingo! is active
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the user is the instructor for the course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user clicks "Copy"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
     And set the new course start date to "5/20/1976"
     And the user executes the copy
    #Let's check what we've got
     And the user will see "successfully"
    Then the user sees 2 course
    Then retrieve the latest course from the db
     And the course "Name" field is "Copy of to dup"
     And the course "Number" field is "Copy of d6"
     And the course "Description" field is "ohla!"
     And the course start date is "5/20/1976" and the end date is "11/11/2012"
     And the course "timezone" is "Mexico City"
     And the course has 1 instructor user
     And the course instructor is the user
    #check the experience
    Then retrieve the 1 course 'experience'
    Then the Experience 'name' is 'cup'
    Then the 'Experience' dates are "6/30/1976" and "8/30/1976"
     And the 'Experience' is 'not' active
    #check the project
    Then retrieve the 1 course 'project'
    Then the new project metadata is the same as the old
    Then the 'project' dates are '5/22/1976' and '10/11/2012'
    Then the project has 0 groups
     And the 'project' is 'not' active
    #check the bingo
    Then retrieve the 1 course 'bingo'
    Then the new bingo metadata is the same as the old
     And the 'bingo' is 'not' active
    Then the 'bingo' dates are '5/30/1976' and '7/30/1976'

  Scenario: Admin duplicates an existing course with a bingo but no project
    Given the course started "5/10/1976" and ended "11/01/2012"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the course 'Name' is 'to dup'
    Given the course 'Number' is 'd6'
    Given the course 'Description' is 'ohla!'
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the course has a Bingo! game
    Given the Bingo! started "5/20/1976" and ends "7/20/1976"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the Bingo! "Topic" is "Private"
    Given the Bingo! "Description" is "this is neat"
    Given the Bingo! "Terms count" is 20
    Given the Bingo! prep days is 2
    Given the Bingo! percent discount is 30
    Given the Bingo! is active
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the user is the instructor for the course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user sees 1 course
    Then the user clicks "Copy"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
     And set the new course start date to "5/20/1976"
     And the user executes the copy
    #Let's check what we've got
     And the user will see "successfully"
    Then the user sees 2 course
    Then retrieve the latest course from the db
     And the course "Name" field is "Copy of to dup"
     And the course "Number" field is "Copy of d6"
     And the course "Description" field is "ohla!"
     And the course start date is "5/20/1976" and the end date is "11/11/2012"
     And the course "timezone" is "Mexico City"
     And the course has 1 instructor user
     And the course instructor is the user
    #check the bingo
    Then retrieve the 1 course 'bingo'
    Then the new bingo metadata is the same as the old
     And the 'bingo' is 'not' active
    Then the 'bingo' dates are '5/30/1976' and '7/30/1976'

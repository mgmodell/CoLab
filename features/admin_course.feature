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
     Then the course has 12 "enrolled student" users
    # 12 confirmed students
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course started "5/10/1970" and ended "4 months hence"
    Given the project started '5/12/1976' and ends '10/01/2012'
    Given the course started "5/10/1976" and ended "11/01/2012"

@javascript
  Scenario: Instructor downloads self-registration image
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user sees self-registration image
    Then the user clicks "Download self-registration code"

  @javascript
  Scenario: Instructor approves student self-registration
    Given the user is the instructor for the course
    Given the course adds 1 "requesting student" users
     Then retrieve the instructor user
    Given the user logs in
     Then the user sees 1 enrollment request
     Then the user "approves" 1 enrollment request
     Then the course has 13 "enrolled student" users

  @javascript
  Scenario: Instructor rejects student self-registration
    Given the user is the instructor for the course
    Given the course adds 2 "requesting student" users
     Then retrieve the instructor user
    Given the user logs in
     Then the user sees 2 enrollment request
     Then the user "rejects" 2 enrollment request
     Then the course has 12 "enrolled student" users
     Then the course has 2 "rejected student" users

@javascript
  Scenario: Admin creates a new course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
     And the user clicks the "New course" button
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the "course" start date to "tomorrow" and the end date to "next month"
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then close all messages
    Then the user clicks "Create Course"
     And the user will see "successfully"
     Then close all messages
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is "099"
     And the course "Description" field is "I love to eat peas and carrots all day long"
     And the course start date is "tomorrow" and the end date is "next month"
     And the course "timezone" is "Nairobi"

@javascript
  Scenario: Admin cannot creates an incomplete new course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
     And the user clicks the "New course" button
     #no name
     And the user sets the "Name" field to ""
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
    Then the user sets the "course" start date to "tomorrow" and the end date to "next month"
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then the user clicks "Create Course"
     And the user will see "Please review the problems below"
     Then close all messages
#     #no start date
#     And the user sets the "Name" field to "Off"
#     And the user sets the "Number" field to "099"
#     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
#     And the user sets the start date to "" and the end date to "next month"
#    Then the user clicks "Create Course"
#     And the user will see "Please review the problems below"
#     Then close all messages
#     #no end date
#     And the user sets the "Name" field to "Off"
#     And the user sets the "Number" field to "099"
#     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
#     And the user sets the start date to "tomorrow" and the end date to ""
#     And the timezone "is" "Nairobi"
#     And the timezone "isn't" "Mexico City"
#    Then the user clicks "Create Course"
#     And the user will see "Please review the problems below"
#     Then close all messages
     #no number or description
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to ""
     And the user sets the "Description" field to ""
     And the user sets the "course" start date to "tomorrow" and the end date to "next month"
     And the timezone "is" "Nairobi"
     And the timezone "isn't" "Mexico City"
    Then close all messages
    Then the user clicks "Create Course"
     #We should have success now
     And the user will see "successfully"
     Then close all messages
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is ""
     And the course "Description" field is ""
     And the course start date is "tomorrow" and the end date is "next month"
     And the course "timezone" is "Nairobi"

@javascript
  Scenario: Instructor cannot create a new course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user does not see a "New Course" link

@javascript
  Scenario: Admin edits an existing course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    #Then the user clicks "Edit Course Details"
     And the user sets the "Name" field to "Off"
     And the user sets the "Number" field to "099"
     And the user sets the "Description" field to "I love to eat peas and carrots all day long"
     And the user sets the "course" start date to "5/11/1976" and the end date to "next month"
     And the timezone "is" "Mexico City"
     And the user sets the course timezone to "Nairobi"
    Then close all messages
    Then the user clicks "Save Course"
     And the user will see "successfully"
     Then close all messages
    Then the user sees the 'course' 'start date' is '05/11/1976'
    Then the user sees the 'course' 'end date' is 'next month'
    Then retrieve the latest course from the db
     And the course "Name" field is "Off"
     And the course "Number" field is "099"
     And the course "Description" field is "I love to eat peas and carrots all day long"
     And the course start date is "5/11/1976" and the end date is "next month"
     And the course "timezone" is "Nairobi"

@javascript
  Scenario: Admin adds an existing student to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Given 1 users
    Then the user adds the 'student' users 'user_list'
    Then there are 13 students in the course
    Then the users are students

@javascript
  Scenario: Admin adds a new student to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'student' users 'me@mailinator.com'
    Then there are 13 students in the course

@javascript
  Scenario: Admin adds a the same student multiple times with different
      capitalization student to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'student' users 'me@mailinator.com'
    Then the user adds the 'student' users 'ME@MAILINATOR.COM'
    Then the user adds the 'student' users 'me@mAiliNator.Com'
    Then the user adds the 'student' users 'me@mailinator.com'
    Then the user adds the 'student' users 'mE@mAILinator.com'
    Then the user adds the 'student' users 'mE@mAILinaTor.com'
    Then there are 13 students in the course

@javascript
  Scenario: Admin adds a new student, then drops and re-adds them
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'student' users 'me@mailinator.com'
    Then there are 13 students in the course
    Then the user drops the 'student' users 'me@mailinator.com'
    Then there are 12 enrolled students in the course
    Then the user adds the 'student' users 'me@mailinator.com'
    Then there are 13 enrolled students in the course

@javascript
  Scenario: Admin adds existing students to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Given 5 users
    Then the user adds the 'student' users 'user_list'
    Then there are 17 students in the course
    Then the users are students

@javascript
  Scenario: Admin adds existing students, then drops and re-adds them
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Given 5 users
    Then the user adds the 'student' users 'user_list'
    Then there are 17 students in the course
    Then the users are students
    Then the user drops the 'student' users 'user_list'
    Then there are 12 enrolled students in the course
    Then the user adds the 'student' users 'user_list'
    Then there are 17 enrolled students in the course
    Then the users are students

@javascript
  Scenario: Admin adds new students to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'student' users 'me@mailinator.com, you@mailinator.com, myself@mailinator.com'
    Then there are 15 students in the course
    Then the users are students

@javascript
  Scenario: Malformed email address returns an error
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'instructor' users 'me@mailinator.com<'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then close all messages
    Then the user adds the 'instructor' users 'me@mailinator.com>'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then close all messages
    Then the user adds the 'instructor' users 'me@mailinator'
    Then there are 1 instructors in the course
     And the user will see "Was there a typo?"
    Then close all messages
    Then the user adds the 'instructor' users 'lme@mailinator.com eweq.wer'
    Then there are 2 instructors in the course
     And the user will see "One instructor has been invited"
    Then the user adds the 'instructor' users 'memailinator.com<'
    Then there are 2 instructors in the course
     And the user will see "Was there a typo?"

@javascript
  Scenario: Admin adds an instructor to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Then the user adds the 'instructor' users 'me@mailinator.com'
    Then there are 2 instructors in the course

@javascript
  Scenario: Admin adds 5 existing instructors to a course
    Given the user is the instructor for the course
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then the user opens the course
    Given 5 users
    Then the user adds the 'instructor' users 'user_list'
    Then there are 6 instructors in the course
    Then the users are instructors

  @javascript
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
    Given the course has an assignment named "Sack Troy" with an "unpublished" rubric named "Trojan War Diorama"
    Given the assignment opening is "2/11/1985" and close is "7/12/2003"
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
    Given the user is the instructor for the course
    Given the user is an admin
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then close all messages
    Then the user clicks the course 'Make a copy' button
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
     And set the new course start date to "5/20/1976"
     And the user executes the copy
    #Let's check what we've got
     And the user will see "successfully"
     Then close all messages
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
    #check the assignment
    Then retrieve the 1 course 'assignment'
    Then the new assignment metadata is the same as the old
     And the 'assignment' is 'not' active
    Then the 'assignment' dates are '2/21/1985' and '7/22/2003'

  @javascript
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
    Then the user selects the 'Courses' menu item
    Then the user sees 1 course
    Then close all messages
    Then the user clicks the course 'Make a copy' button
     And the course start date is "5/10/1976" and the end date is "11/01/2012"
     And set the new course start date to "5/20/1976"
     And the user executes the copy
    #Let's check what we've got
     And the user will see "successfully"
     Then close all messages
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

Feature: Generate diversity scores (DS)
  Test our ability to generate diversity scores for our groups
  and then to regenerate them upon changes being made.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users

  Scenario: With no demographics entered, DS will be 0
     Then we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: 1 gender gives us a DS of 2
     Then the "gender" of the "random" group user is "f"
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 2 different genders gives us a DS of 4
     Then the "gender" of the "first" group user is "f"
     Then the "gender" of the "last" group user is "nb"
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 3 different genders gives us a DS of 6
     Then the "gender" of the "first" group user is "f"
     Then the "gender" of the "third" group user is "m"
     Then the "gender" of the "last" group user is "nb"
     Then we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 3 different genders and one non-answer gives us a DS of 6
     Then the "gender" of the "first" group user is "f"
     Then the "gender" of the "third" group user is "m"
     Then the "gender" of the "last" group user is "__"
     Then we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 2 different states in the same country gives us a DS of 2
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 2 selected states in different home countries gives us a DS of 4
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 2 countries with just one selected state gives a DS of 3
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 4 users with no language response DS:0
     Then the "language" of the "first" group user is "__"
     Then the "language" of the "last" group user is "__"
     Then the "language" of the "third" group user is "__"
     Then the "language" of the "second" group user is "__"
     Then we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: 2 distinct but repeated languages DS:4
     Then the "language" of the "first" group user is "ko"
     Then the "language" of the "last" group user is "ko"
     Then the "language" of the "third" group user is "fj"
     Then the "language" of the "second" group user is "fj"
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 3 users with the same language DS:2
     Then the "language" of the "last" group user is "zu"
     Then the "language" of the "third" group user is "zu"
     Then the "language" of the "second" group user is "zu"
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 3 different home languages and one non gives us a DS of 6
     Then the "language" of the "first" group user is "__"
     Then the "language" of the "last" group user is "ga"
     Then the "language" of the "third" group user is "qu"
     Then the "language" of the "second" group user is "en"
     Then we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 2 different home languages gives us a DS of 4
     Then the "language" of the "first" group user is "bn"
     Then the "language" of the "last" group user is "gd"
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 1 home languages gives us a DS of 2
     Then the "language" of the "random" group user is "sr"
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 15 completed scenarios gives us a DS of 12
     Then we update the group's diversity score
     Then the group's diversity score is 12

  Scenario: 7 different scenarios gives us a DS of 7
     Then we update the group's diversity score
     Then the group's diversity score is 7

  Scenario: 2 different incomplete scenarios gives us a DS of 2
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 2 different incomplete scenarios gives us a DS of 2
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: DOBs of 1980 and 1976 give a DS of 2
     Then the "dob" of the "first" group user is "5/10/1976"
     Then the "dob" of the "last" group user is "2/29/1980"
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: DOBs of 1980, 1976 and 2008 give a DS of 14
     Then the "dob" of the "first" group user is "5/10/1976"
     Then the "dob" of the "second" group user is "2/29/1980"
     Then the "dob" of the "third" group user is "7/10/2008"
     Then we update the group's diversity score
     Then the group's diversity score is 14

  Scenario: A Uni. start of 2015 give a DS of 0
     Then we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: Uni. starts of 2015, 2011, 2014 and 2015 give a DS of 2
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: If we add a member to a group, the DS automatically updates
     Then we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: If a DS:3 group makes a demographic change, the DS does not update automatically
     Then we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: If an all-male group (DS:1) group adds a gender-non-binary, then DS:2
    Given the course has 1 confirmed users
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: A group with one user with all demographics completed - DS:0
    Given the project has a group with 1 confirmed users
     Then we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: A proposed group from 1 male user - DS:0
    Given the course has 1 confirmed users
     Then the "gender" of the "random" group user is "m"
     Then the score calculated from the users is 0

  Scenario: A proposed group from 4 users with 2 genders gives a ds of 2
    Given the course has 4 confirmed users
     Then the "gender" of the "first" group user is "m"
     Then the "gender" of the "last" group user is "f"
     Then the score calculated from the users is 2

  Scenario: Diversity combinations (2 gender + 2 lang) are additive
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: Diversity combination (full on)
    #2011, 2012, 2011, 2011
    #M + F
    #1 Country + 2 Provinces
    #1996, 1997, 1998, 1997
    #4 scenarios
    #2 languages
    #2 CIP
     Then the group's diversity score is 16

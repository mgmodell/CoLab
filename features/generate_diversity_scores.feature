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

  Scenario: 2 different genders gives us a DS of 4
     Then the "random" user is "Female"
     Then we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 3 different genders gives us a DS of 6
     Then the "first" user is "Female"
     Then the "third" user is "Male"
     Then the "last" user is "Non-binary"
     Then we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 3 different genders and one non-answer gives us a DS of 6
     Then the "first" user is "Female"
     Then the "third" user is "Male"
     Then the "last" user is "I prefer not to answer"
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

  Scenario: 4 different home languages gives us a DS of 4
     Then we update the group's diversity score
     Then the group's diversity score is 4

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
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: DOBs of 1980, 1976 and 2008 give a DS of 14
     Then we update the group's diversity score
     Then the group's diversity score is 14

  Scenario: A Uni. start of 2015 give a DS of 0
     Then we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: Uni. starts of 2015, 2011, 2014 and 2015 give a DS of 2
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: If a DS:3 group makes a demographic change, the DS does not update automatically
     Then we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: If an all-male group (DS:1) group adds a gender-non-binary, then DS:2
    Given the course has 1 confirmed users
     Then we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: A proposed group from 4 users with 2 genders gives a ds of 2
    Given the course has 4 confirmed users
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

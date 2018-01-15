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
     When we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: 1 gender gives us a DS of 2
    Given the "gender" of the "random" "group" user is "f"
     When we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 3 CIPS representing 2 different courses of study gives us a DS:4
    Given the "cip" of the "first" "group" user is "46"
    Given the "cip" of the "last" "group" user is "9"
    Given the "cip" of the "third" "group" user is "46"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 2 different courses of study and one non-answer gives us a DS:4
    Given the "cip" of the "first" "group" user is "13"
    Given the "cip" of the "last" "group" user is "47"
    Given the "cip" of the "third" "group" user is "0"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 2 different courses of study gives us a DS:2
    Given the "cip" of the "first" "group" user is "13"
    Given the "cip" of the "last" "group" user is "47"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 2 different genders gives us a DS of 4
    Given the "gender" of the "first" "group" user is "f"
    Given the "gender" of the "last" "group" user is "nb"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 3 different genders gives us a DS of 6
    Given the "gender" of the "first" "group" user is "f"
    Given the "gender" of the "third" "group" user is "m"
    Given the "gender" of the "last" "group" user is "nb"
     When we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 3 different genders and one non-answer gives us a DS of 6
    Given the "gender" of the "first" "group" user is "f"
    Given the "gender" of the "third" "group" user is "f"
    Given the "gender" of the "second" "group" user is "nb"
    Given the "gender" of the "third" "group" user is "m"
    Given the "gender" of the "last" "group" user is "__"
     When we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 2 different states in the same country gives us a DS of 3
    Given the "first" "group" user is from "NY" in "US"
    Given the "last" "group" user is from "VT" in "US"
     When we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: 2 selected states in different home countries gives us a DS of 4
    Given the "first" "group" user is from "NY" in "US"
    Given the "last" "group" user is from "47" in "KR"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 2 countries with just one selected state gives a DS of 3
    Given the "first" "group" user is from "NY" in "US"
    Given the "last" "group" user is from "__" in "KR"
     When we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: 4 users with no language response DS:0
    Given the "language" of the "first" "group" user is "__"
    Given the "language" of the "last" "group" user is "__"
    Given the "language" of the "third" "group" user is "__"
    Given the "language" of the "second" "group" user is "__"
     When we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: 2 distinct but repeated languages DS:4
    Given the "language" of the "first" "group" user is "ko"
    Given the "language" of the "last" "group" user is "ko"
    Given the "language" of the "third" "group" user is "fj"
    Given the "language" of the "second" "group" user is "fj"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 3 users with the same language DS:2
    Given the "language" of the "last" "group" user is "zu"
    Given the "language" of the "third" "group" user is "zu"
    Given the "language" of the "second" "group" user is "zu"
     When we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 3 different home languages and one non gives us a DS of 6
    Given the "language" of the "first" "group" user is "__"
    Given the "language" of the "last" "group" user is "ga"
    Given the "language" of the "third" "group" user is "qu"
    Given the "language" of the "second" "group" user is "en"
     When we update the group's diversity score
     Then the group's diversity score is 6

  Scenario: 2 different home languages gives us a DS of 4
    Given the "language" of the "first" "group" user is "bn"
    Given the "language" of the "last" "group" user is "gd"
     When we update the group's diversity score
     Then the group's diversity score is 4

  Scenario: 1 home languages gives us a DS of 2
    Given the "language" of the "random" "group" user is "sr"
     When we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 15 completed scenarios gives us a DS of 12
    Given the course has an experience
    Given the experience started "last month" and ends "tomorrow"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #experience 2
    Given the course has an experience
    Given the experience started "3 days from now" and ends "7 days from now"
    Given the experience "has" been activated
    Given today is "5 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #experience 3
    Given the course has an experience
    Given the experience started "10 days from now" and ends "20 days from now"
    Given the experience "has" been activated
    Given today is "15 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #experience 4
    Given the course has an experience
    Given the experience started "23 days from now" and ends "27 days from now"
    Given the experience "has" been activated
    Given today is "25 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

     When we update the group's diversity score
     Then the group's diversity score is 12

  Scenario: 7 different scenarios gives us a DS of 7
    Given the course has an experience
    Given the experience started "last month" and ends "tomorrow"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #Next experience
    Given the course has an experience
    Given the experience started "3 days from now" and ends "7 days from now"
    Given the experience "has" been activated
    Given today is "5 days from now"

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

     When we update the group's diversity score
     Then the group's diversity score is 7

  Scenario: 2 complete scenarios gives us a DS of 2
    Given the course has an experience
    Given the experience started "last month" and ends "next month"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user successfully completes an experience
     Then the user logs out

     When we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: 3 different incomplete scenarios gives us a DS of 3
    Given the course has an experience
    Given the experience started "last month" and ends "next month"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user logs out

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user completes a week
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user completes a week
     Then the user completes a week
     Then the user completes a week
     Then the user completes a week
     Then the user logs out

     When we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: DOBs of 1980 and 1976 give a DS of 2
    Given the "dob" of the "first" "group" user is "5/10/1976"
    Given the "dob" of the "last" "group" user is "2/29/1980"
     When we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: DOBs of 1980, 1976 and 2008 give a DS of 14
    Given the "dob" of the "first" "group" user is "5/10/1976"
    Given the "dob" of the "second" "group" user is "2/29/1980"
    Given the "dob" of the "third" "group" user is "7/10/2008"
     When we update the group's diversity score
     Then the group's diversity score is 14

  Scenario: A Uni. start of 2015 give a DS of 0
    Given the "uni_date" of the "random" "group" user is "8/28/2015"
     When we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: Uni. starts of 2015, 2011, 2014 and 2015 give a DS of 2
    Given the "uni_date" of the "last" "group" user is "8/28/2015"
    Given the "uni_date" of the "second" "group" user is "8/28/2011"
    Given the "uni_date" of the "first" "group" user is "5/28/2014"
    Given the "uni_date" of the "third" "group" user is "1/01/2015"
     When we update the group's diversity score
     Then the group's diversity score is 2

  Scenario: If we add a member to a group, the DS automatically updates
    Given the "first" "group" user is from "NY" in "US"
    Given the "last" "group" user is from "VT" in "US"
    Given the "second" "group" user is from "KN" in "CD"
     When we update the group's diversity score
     Then the group's diversity score is 5
     When we remove the "second" user
     Then we update the group's diversity score
     Then the group's diversity score is 3

  Scenario: If a DS:3 group makes a demographic change, the DS does not auto-update
    Given the "first" "group" user is from "NY" in "US"
    Given the "last" "group" user is from "VT" in "US"
     When we update the group's diversity score
     Then the group's diversity score is 3
    Given the "second" "group" user is from "KN" in "CD"
     Then the group's diversity score is 3
     When we update the group's diversity score
     Then the group's diversity score is 5

  Scenario: If an all-male group (DS:2) group adds a gender-non-binary, then DS:4
    Given the "gender" of the "first" "group" user is "m"
    Given the "gender" of the "second" "group" user is "m"
    Given the "gender" of the "third" "group" user is "m"
    Given the "gender" of the "last" "group" user is "m"
     When we update the group's diversity score
    Given the course has 4 confirmed users
    Given the "gender" of the "first" "loose" user is "f"
     Then the group's diversity score is 2
     Then the "first" "loose" user is added to the group
     Then the group's diversity score is 4

  Scenario: A group with one user with all demographics completed - DS:0
    Given the project has a group with 1 confirmed users
     When we update the group's diversity score
     Then the group's diversity score is 0

  Scenario: A proposed group from 1 male user - DS:0
    Given the course has 1 confirmed users
    Given the "gender" of the "random" "loose" user is "m"
     Then the score calculated from the users is 0

  Scenario: A proposed group from 4 users with 2 different impairments gives a ds of 3
    Given the course has 4 confirmed users
    Given the "impairment" of the "first" "loose" user is "visual"
    Given the "impairment" of the "last" "loose" user is "motor"
     Then the score calculated from the users is 3

  Scenario: A proposed group from 4 users with 1 impaired user gives a ds of 2
    Given the course has 4 confirmed users
    Given the "impairment" of the "last" "loose" user is "cognitive"
     Then the score calculated from the users is 3

  Scenario: A proposed group from 4 users with 2 different like impairments gives a ds of 2
    Given the course has 4 confirmed users
    Given the "impairment" of the "first" "loose" user is "cognitive"
    Given the "impairment" of the "last" "loose" user is "cognitive"
     Then the score calculated from the users is 3

  Scenario: A proposed group from 4 users with 2 different combo impairments gives a ds of 3
    Given the course has 4 confirmed users
    Given the "impairment" of the "first" "loose" user is "visual"
    Given the "impairment" of the "last" "loose" user is "visual"
    Given the "impairment" of the "last" "loose" user is "motor"
     Then the score calculated from the users is 3

  Scenario: A proposed group from 4 users with 2 genders gives a ds of 2
    Given the course has 4 confirmed users
    Given the "gender" of the "first" "loose" user is "m"
    Given the "gender" of the "last" "loose" user is "f"
     Then the score calculated from the users is 4

  Scenario: Diversity combinations (4 gender + 4 lang) are additive
    Given the "gender" of the "second" "group" user is "f"
    Given the "gender" of the "third" "group" user is "nb"
    Given the "language" of the "last" "group" user is "ty"
    Given the "language" of the "first" "group" user is "lo"
     When we update the group's diversity score
     Then the group's diversity score is 8

  Scenario: Diversity combination (full on)
    #2011, 2012, 2011, 2011
    Given the "dob" of the "first" "group" user is "5/28/2011"
    Given the "dob" of the "second" "group" user is "5/28/2012"
    Given the "dob" of the "third" "group" user is "5/28/2011"
    Given the "dob" of the "last" "group" user is "5/28/2011"
    #M + F
    Given the "gender" of the "second" "group" user is "f"
    Given the "gender" of the "third" "group" user is "m"
    #1 Country + 2 Provinces
    Given the "first" "group" user is from "CA" in "US"
    Given the "last" "group" user is from "CT" in "US"
    #1996, 1997, 1998, 1997
    Given the "uni_date" of the "first" "group" user is "5/28/1996"
    Given the "uni_date" of the "second" "group" user is "5/28/1997"
    Given the "uni_date" of the "last" "group" user is "5/28/1998"
    Given the "uni_date" of the "third" "group" user is "5/28/1997"
    #4 scenarios
    Given the course has an experience
    Given the experience started "last month" and ends "next month"
    Given the experience "has" been activated
    Given the users "have" had demographics requested
    #The second user
    Given the user is "the second" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user logs out

    #The third user
    Given the user is "the third" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user completes a week
     Then the user logs out

    #The first user
    Given the user is "the first" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user completes a week
     Then the user logs out

    #The last user
    Given the user is "the last" user
     Then the user logs in
     Then the user should see a successful login message
     Then user should see 1 open task
     Then the user clicks the link to the experience
     Then the user sees the experience instructions page
      And the user presses "Next"
     Then the user completes a week
     Then the user completes a week
     Then the user completes a week
     Then the user completes a week
     Then the user completes a week
     Then the user logs out

    #2 languages
    Given the "language" of the "last" "group" user is "zu"
    Given the "language" of the "first" "group" user is "ga"
    #2 CIP
    Given the "cip" of the "last" "group" user is "46"
    Given the "cip" of the "third" "group" user is "11"
     When we update the group's diversity score
     #TODO correct this number
     Then the group's diversity score is 20

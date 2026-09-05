Feature: Generate faultline strength (ASW)
  Test our ability to generate faultline strength for groups
  and proposed groups using normalized email matching.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the user is the instructor for the course
    Given the project has a group with 4 confirmed users

  Scenario: With no demographics entered, faultline strength will be 0
    When we update the group's faultline strength
    Then the group's faultline strength is 0

  Scenario: Two aligned subgroups produce a positive faultline strength
    Given the "gender" of the "first" "group" user is "m"
    Given the "gender" of the "second" "group" user is "m"
    Given the "gender" of the "third" "group" user is "f"
    Given the "gender" of the "last" "group" user is "f"
    Given the "language" of the "first" "group" user is "en"
    Given the "language" of the "second" "group" user is "en"
    Given the "language" of the "third" "group" user is "fr"
    Given the "language" of the "last" "group" user is "fr"
    Given the "cip" of the "first" "group" user is "13"
    Given the "cip" of the "second" "group" user is "13"
    Given the "cip" of the "third" "group" user is "47"
    Given the "cip" of the "last" "group" user is "47"
    Given the "first" "group" user is from "NY" in "US"
    Given the "second" "group" user is from "NY" in "US"
    Given the "third" "group" user is from "VT" in "US"
    Given the "last" "group" user is from "VT" in "US"
    Given the "dob" of the "first" "group" user is "1/1/2000"
    Given the "dob" of the "second" "group" user is "1/1/2000"
    Given the "dob" of the "third" "group" user is "1/1/1990"
    Given the "dob" of the "last" "group" user is "1/1/1990"
    Given the "uni_date" of the "first" "group" user is "1/1/2018"
    Given the "uni_date" of the "second" "group" user is "1/1/2018"
    Given the "uni_date" of the "third" "group" user is "1/1/2010"
    Given the "uni_date" of the "last" "group" user is "1/1/2010"
    When we update the group's faultline strength
    Then the group's faultline strength is greater than 0.25

  Scenario: Proposed-group faultline score handles case, spaces, and duplicate emails
    Given the "gender" of the "first" "group" user is "m"
    Given the "gender" of the "second" "group" user is "m"
    Given the "gender" of the "third" "group" user is "f"
    Given the "gender" of the "last" "group" user is "f"
    Then the normalized proposed-group faultline score matches the group's users

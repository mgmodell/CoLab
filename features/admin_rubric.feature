Feature: Rubric administration
  Test our ability to perform basic administrative
  tasks on an incrementally submittable assignment.

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given there is a course with an assessed project
    Given the course has 8 confirmed users
    Given the course timezone is "Mexico City"
    Given the user timezone is "Nairobi"
    Given the course has an assignment
    Given the course started "5/10/1976" and ended "5 months from now"
    Given the project started "5/10/1976" and ends "11/01/2012", opened "Saturday" and closes "Monday"
    Given the assignment's first deadline is "2/29/1980" and final is "7/10/2008"
    Given the course started "5/10/1976" and ended "11/01/2012"

  Scenario: Instructor creates a rubric
  Scenario: Instructor publishes a rubric
  Scenario: Instructor unpublishes a rubric
  Scenario: Instructor adds a row to a rubric
  Scenario: Instructor removes a row from a rubric
  Scenario: Instructor copies a public rubric
  Scenario: Instructor copies their own rubric
  Scenario: Instructor tries to copy a non-public rubric
  Scenario: Instructor adds a counter element to a rubric
  Scenario: Instructor removes a counter element from a rubric
  Scenario: Instructor modifies a rubric
  Scenario: Instructor searches for an existing rubric
  Scenario: Instructor deletes a rubric
  Scenario: Instructor deletes a rubric that is in use


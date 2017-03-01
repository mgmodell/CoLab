Feature: Creating Inside Assessments
  The system must create exactly one assessment during each open period for each open project
  So that students can properly respond.
  These assessments are simple Sun - Sat. with no wrap-around.

  Background:
    Given there is a course with an assessed project
    Given today is "January 1, 2012"
    Given today is "next Monday"
    Given the project started "January 1, 2012" and ends "February 1, 2012", opened "Monday" and closes "Friday"

  Scenario: if an project is activated when it is open, an assessment will be added to it
    Given the project has been activated
    Then the project should have 1 assessments attached to it

  Scenario: if an project is activated when it is not open, no assessment will be added to it
    Given today is "one month ago"
    Given the project has been activated
    Then the project should have 0 assessments attached to it
    Given that the system's set_up_assessments process runs
    Then the project should have 0 assessments attached to it

  Scenario: if the set_up_assessment process runs twice when an activated project is open, only one assessment will be added to it
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it

  Scenario: if the set_up_assessment process runs every day for a week,  only one assessment will be added
    Given the project has been activated
    Given that the system's set_up_assessments process runs
    Given today is "tomorrow"
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it
    Given today is "tomorrow"
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it
    Given today is "tomorrow"
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it
    Given today is "tomorrow"
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it
    Given today is "tomorrow"
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it

  Scenario: if the set_up_assessment process runs on successive days when an project is open, only one assessment will be added to it
    Given the project has been activated
    Given today is "tomorrow"
    Given that the system's set_up_assessments process runs
    Then the project should have 1 assessments attached to it

  Scenario: if the set_up_assessment process runs on 3 successive weeks when projects are open, three assessments will be attached
    Given the project has been activated
    Given today is "next Monday"
    Given that the system's set_up_assessments process runs
    Given that the system's set_up_assessments process runs
    Then the project should have 2 assessments attached to it
    Given today is "next week"
    Given that the system's set_up_assessments process runs
    Given that the system's set_up_assessments process runs
    Then the project should have 3 assessments attached to it

  Scenario: if the set_up_assessment process runs on three successive weeks when projects are open, four assessments will be attached
    Given the project has been activated
    Given today is "next Monday"
    Given that the system's set_up_assessments process runs
    Given that the system's set_up_assessments process runs
    Then the project should have 2 assessments attached to it
    Given today is "next week"
    Given that the system's set_up_assessments process runs
    Given that the system's set_up_assessments process runs
    Then the project should have 3 assessments attached to it
    Given today is "next week"
    Given that the system's set_up_assessments process runs
    Given that the system's set_up_assessments process runs
    Then the project should have 4 assessments attached to it


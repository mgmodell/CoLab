Feature: Creating Same Day Assessments
  The system must create exactly one assessment during each open period for each open project
  So that students can properly respond.
  These weeklies are only open for a single day.

  Background:
    Given there is a course with an assessed project
    Given today is "January 1, 2012"
    Given today is "this Monday"
    Given the project started "January 1, 2012" and ends "February 1, 2012", opened "Monday" and closes "Monday"

  Scenario: if an assessment is activated when it is open, an assessment will be added to it
    Given the assessment has been activated
    Then the assessment should have 1 weekly attached to it
    Then return to the present

  Scenario: if an assessment is activated when it is not open, no assessment will be added to it
    Given today is "one month ago"
    Given the assessment has been activated
    Then the assessment should have 0 weekly attached to it
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 0 weekly attached to it
    Then return to the present

  Scenario: if the set_up_weekly process runs twice when an activated assessment is open, only one assessment will be added to it
    Given the assessment has been activated
    Given that the system's set_up_weeklies process runs
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Then return to the present

  Scenario: if the set_up_weekly process runs every day for a week,  only one assessment will be added
    Given the assessment has been activated
    Given that the system's set_up_weeklies process runs
    Given today is "tomorrow"
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Given today is "tomorrow"
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Given today is "tomorrow"
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Given today is "tomorrow"
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Given today is "tomorrow"
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Then return to the present

  Scenario: if the set_up_weekly process runs on successive days when an assessment is open, only one assessment will be added to it
    Given the assessment has been activated
    Given today is "tomorrow"
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 1 weekly attached to it
    Then return to the present

  Scenario: if the set_up_weekly process runs on 3 successive weeks when assessments are open, three weeklies will be attached
    Given the assessment has been activated
    Then the assessment should have 1 weekly attached to it
    Given today is "7 days from now"
    Given that the system's set_up_weeklies process runs
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 2 weekly attached to it
    Given today is "7 days from now"
    Given that the system's set_up_weeklies process runs
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 3 weekly attached to it
    Then return to the present

  Scenario: if the set_up_weekly process runs on 4 successive weeks when assessments are open, four weeklies will be attached
    Given the assessment has been activated
    Then the assessment should have 1 weekly attached to it
    Given today is "7 days from now"
    Given that the system's set_up_weeklies process runs
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 2 weekly attached to it
    Given today is "7 days from now"
    Given that the system's set_up_weeklies process runs
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 3 weekly attached to it
    Given today is "7 days from now"
    Given that the system's set_up_weeklies process runs
    Given that the system's set_up_weeklies process runs
    Then the assessment should have 4 weekly attached to it
    Then return to the present


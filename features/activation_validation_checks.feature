Feature: Activation Validation Checks
  In order to make sure active projects are properly constructed,
  The System must check them on activation.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users

  Scenario: It should not be possible to activate assesments where no Factor Pack is set
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    When the project is activated
    Then there should be 1 project save errors

  Scenario: It should be possible to activate assesments where no participants appear more than once
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    When the project is activated
    Then there should be 0 project save errors

  Scenario: It should not be possible to activate an project with a repeated user
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    Given an additional user is in each group of the project
    Given the factor pack is set to "Original"
    When the project is activated
    Then there should be 1 project save errors

#TODO: Add in timezone checking support
  Scenario: It should be possible to activate assesments where no participants appear more than once
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the factor pack is set to "Original"
    When the project is activated
    Then there should be 0 project save errors

  Scenario: It should not be possible to activate an project with a repeated user
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    Given an additional user is in each group of the project
    Given the factor pack is set to "Original"
    When the project is activated
    Then there should be 1 project save errors

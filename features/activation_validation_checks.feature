Feature: Activation Validation Checks
  In order to make sure active projects are properly constructed,
  The System must check them on activation.

  Background:
    Given there is a course with an assessed project
    Given the project has a group with 4 confirmed users

  Scenario: It should be possible to activate assesments where no participants appear more than once
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    When the project is activated
    Then there should be no errors

  Scenario: It should not be possible to activate an project with a repeated user
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    Given an additional user is in each group of the project
    When the project is activated
    Then there should be one error

  Scenario: It should not be possible to modify an active project
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    When the project is activated
    Then there should be an error if I try to modify an project field
    And there should be an error if I try to modify a group that is part of an active project

#TODO: Add in timezone checking support
  Scenario: It should be possible to activate assesments where no participants appear more than once
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    When the project is activated
    Then there should be no errors

  Scenario: It should not be possible to activate an project with a repeated user
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    Given an additional user is in each group of the project
    When the project is activated
    Then there should be one error

  Scenario: It should not be possible to modify an active project
    Given the project started "last month" and ends "next month", opened "yesterday" and closes "tomorrow"
    Given the project has a group with 4 confirmed users
    When the project is activated
    Then there should be an error if I try to modify an project field
    And there should be an error if I try to modify a group that is part of an active project

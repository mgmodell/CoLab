Feature: Administration: user
  Check that the environment settings are correct and that materials are accessible.

  Background:

  Scenario: Regular users do not see the Admin button 
    Then the AWS keys are available
     And the environment matches that set
    Then we artificially fail for info

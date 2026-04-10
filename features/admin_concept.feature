Feature: Concept Administration
  Test our ability to perform basic administrative
  tasks on a concept. These will mostly not use the interface, but
  rather focus on the back-end.

  Background:
    Given a user has signed up
    Given the user is an admin
    Given 5 multi-word concepts have been added to the system
    Given the user "has" had demographics requested
      And the user's school is "SUNY Korea"

  Scenario: Create a new concept that is all uppercase
    When create a concept named "HAPPY TRAILS"
    Then a concept will exist named "Happy Trails"
    When create a concept named "HAPPY TRAILS (HT)"
    Then a concept will exist named "Happy Trails (ht)"

  Scenario: Create a new concept that is mixed case
    When create a concept named "hApPY TrAiLS to yOu"
    Then a concept will exist named "Happy Trails To You"
    When create a concept named "hApPY TrAiLS (hT) to yOu"
    Then a concept will exist named "Happy Trails (ht) To You"

  Scenario: Create a new concept that is all lowercase
    When create a concept named "the trails are happy!"
    Then a concept will exist named "The Trails Are Happy!"
    When create a concept named "(ttah) the trails are happy!"
    Then a concept will exist named "(ttah) The Trails Are Happy!"

  Scenario: Change the name of a concept to all lowercase
    Then a concept name is set to 'all lowercase'
    Then the concept name is saved in standard form

  Scenario: Change the name of a concept to all uppercase
    Then a concept name is set to 'all uppercase'
    Then the concept name is saved in standard form

  Scenario: Change the name of a concept to mixed case
    Then a concept name is set to 'mixed case'
    Then the concept name is saved in standard form

  @javascript
  Scenario: Change the name of a concept through the Admin functions
    When create a concept named "Conceptually speaking"
    Then a concept will exist named "Conceptually speaking"
    Then the user is an admin
    Then the user logs in
    Then the user clicks the Admin button
    Then the user selects the 'Concepts' menu item
    Then the user updates the "Conceptually Speaking" concept to "Conceptually speaking (CS)"
    Then the user waits to see "successfully"
    Then close all messages
    Then the concept "Conceptually Speaking (cs)" will be in the list
    Then a concept will exist named "Conceptually speaking (cs)"
    Then a concept will not exist named "Conceptually speaking"

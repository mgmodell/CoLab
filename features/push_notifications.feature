Feature: Push notifications
  In order to be reminded of pending activities,
  Users with registered mobile devices receive push notifications.

  Scenario: A registered device is notified of pending activities
    Given there is a course
    Given the course has 1 confirmed users
    Given the user is the most recently created user
    Given the user has a registered push device
    When a push notification is sent to the user
    Then the user's device should be sent a push notification

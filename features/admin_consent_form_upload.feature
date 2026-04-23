Feature: Admin uploads a PDF for a Consent Form
  In order to provide a consent document for research participants,
  Admins must be able to upload a PDF when creating or updating a consent form.
  The uploaded PDF must be properly stored in Active Storage (S3 in production).

  Background:
    Given a user has signed up
    Given the user "has" had demographics requested
    Given the user is an admin

  @javascript
  Scenario: Admin creates a new consent form with a PDF upload
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'consent-forms' menu item
    Then the user clicks the "New consent_form" button
    Then the user sees the consent form editing page
    When the user sets the "Name of the Study" field to "Research Study 2026"
    When the admin uploads a PDF for the consent form
    When the user clicks "Create consent form"
    Then the user waits to see "successfully"
    Then the new consent form has a PDF stored in Active Storage
    Then the admin sees the PDF link on the consent form page

  @javascript
  Scenario: Admin updates an existing consent form with a new PDF upload
    Given there is a consent form without a PDF
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'consent-forms' menu item
    Then the user opens the consent form for editing
    Then the user sees the consent form editing page
    When the admin uploads a PDF for the consent form
    When the user clicks "Save consent form"
    Then the user waits to see "successfully"
    Then the existing consent form has a PDF stored in Active Storage
    Then the admin sees the PDF link on the consent form page

  @javascript
  Scenario: Admin replaces the PDF on an existing consent form that already has one
    Given there is a consent form with an existing PDF
    Given the user logs in
    Then the user "does" see an Admin button
    Then the user clicks the Admin button
    Then the user selects the 'consent-forms' menu item
    Then the user opens the consent form for editing
    Then the user sees the consent form editing page
    Then the admin sees the PDF link on the consent form page
    When the admin uploads a replacement PDF for the consent form
    When the user clicks "Save consent form"
    Then the user waits to see "successfully"
    Then the existing consent form has a PDF stored in Active Storage
    Then the replaced PDF is different from the original PDF
    Then the admin sees the PDF link on the consent form page

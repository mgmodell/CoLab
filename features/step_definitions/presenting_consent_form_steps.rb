# frozen_string_literal: true

require 'chronic'
require 'faker'

Given(/^reset time clock to now$/) do
  travel_back
end

Given(/^there is a global consent form$/) do
  @consent_form = ConsentForm.new(
    name: Faker::Nation.nationality,
    user: User.find(1)
  )
  @consent_form.pdf.attach(io: File.open(
    Rails.root.join('db', 'ConsentForms_consolidated.pdf')
  ),
                           filename: 'cf.pdf',
                           content_type: 'application/pdf')
  @consent_form.save
  log @consent_form.errors.full_messages if @consent_form.errors.present?
end

Given(/^the course has a consent form$/) do
  @consent_form = ConsentForm.new(
    user: User.find(1),
    name: Faker::Nation.nationality
  )
  @consent_form.pdf.attach(io: File.open(
    Rails.root.join('db', 'ConsentForms_consolidated.pdf')
  ),
                           filename: 'cf.pdf',
                           content_type: 'application/pdf')
  @consent_form.save
  log @consent_form.errors.full_messages if @consent_form.errors.present?
  @course.consent_form = @consent_form
  @course.save
  log @course.errors.full_messages if @course.errors.present?
end

Then('user should see a consent form listed for the open experience') do
  page.should have_content 'Research Consent Form'
  page.should have_content @experience.name
end

Then('user should see a consent form listed for the open bingo') do
  page.should have_content 'Research Consent Form'
  page.should have_content @bingo.topic
end

Then(/^user should see a consent form listed for the open project$/) do
  page.should have_content 'Research Consent Form'
  page.should have_content @project.name
end

When(/^user clicks the link to the project, they will be presented with the consent form$/) do
  click_link_or_button @project.name
  page.should have_content 'Please review the document below.'
end

Given(/^the user is the "(.*?)" user in the group$/) do |ordinal|
  @user = if ordinal == 'last'
            @group.users.last
          elsif ordinal == 'first'
            @group.users[0]
          else
            @group.users.sample
          end
end

Given(/^the consent form "(.*?)" been presented to the user$/) do |has_or_has_not|
  presented = has_or_has_not == 'has'
  consent_log = ConsentLog.create(presented:,
                                  user_id: @user.id,
                                  consent_form_id: @consent_form.id)
end

Then(/^user should not see a consent form listed for the open project$/) do
  page.should have_content 'Not for Research'
end

When(/^the user visits the index$/) do
  visit '/'
end

Given(/^the consent form started "([^"]*)" and ends "([^"]*)"$/) do |start_date, end_date|
  @consent_form.start_date = Chronic.parse(start_date)
  @consent_form.end_date = end_date.casecmp('null').zero? ? nil : Chronic.parse(end_date)
  @consent_form.save
  log @consent_form.errors.full_messages unless @consent_form.errors.empty?
end

Given(/^the consent form "([^"]*)" active$/) do |is_active|
  @consent_form.active = is_active == 'is'
  @consent_form.save
  log @consent_form.errors.full_messages unless @consent_form.errors.empty?
end
